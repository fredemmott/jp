#!/usr/bin/env ruby

require 'jp/thrift'
require 'jp_unlocker'
require 'ruby-1.9.0-compat'

require 'mongo'
include Jp

class JpServer
	def initialize options = {}
		options[:default_timeout] ||= 3600 # 1 hour
		options[:port_number] ||= 9090
		options[:mongo_uri] ||= 'mongodb://localhost'
		options[:mongo_pool_size] ||= 10
		options[:mongo_pool_timeout] ||= 60
		options[:mongo_retry_attempts] ||= 10
		options[:mongo_retry_delay] ||=1
		raise ArgumentError.new "mongo_db option must be specified" unless options[:mongo_db]
		raise ArgumentError.new "pools option must be specified" unless options[:pools]
		raise ArgumentError.new "pools option must not be empty" unless ! options[:pools].empty?

		# Setup Thrift server (allowing dependency injection)
		if options.member? :injected_thrift_server then
			@server = options[:injected_thrift_server]
		else
			processor = options[:thrift_processor] # For testing, and allow instrumented server to override
			processor ||= JobPool::Processor.new self
			socket = Thrift::ServerSocket.new options[:port_number]
			transportFactory = Thrift::BufferedTransportFactory.new

			@server = Thrift::ThreadedServer.new processor, socket, transportFactory
		end

		# Connect to mongodb
		if options.member? :injected_mongo_database then
			@database = options[:injected_mongo_database]
		else
			connection = Mongo::Connection.from_uri options[:mongo_uri], {:pool_size => options[:mongo_pool_size], :timeout => options[:mongo_pool_timeout]}
			@database = connection.db options[:mongo_db]
		end

		@pools = Hash.new
		options[:pools].each do |name, data|
			data[:timeout] ||= options[:default_timeout]
			data[:cleanup_interval] ||= data[:timeout]
			@pools[name] = data
		end

		@unlocker = nil
		unless options[:skip_embedded_unlocker]
			if options.member? :injected_unlocker
				@unlocker = options[:injected_unlocker]
			else
				@unlocker = JpUnlocker.new options
			end
		end

		@retry_attempts = options[:mongo_retry_attempts]
		@retry_delay = options[:mongo_retry_delay]

		@start_time = Time.new.to_i
	end

	def serve
		# Look for expired entries
		@unlocker ||= nil
		unlocker_thread = nil
		if @unlocker
			unlocker_thread = Thread.new do
				@unlocker.run
			end
		end
		@server.serve
		unlocker_thread.join if unlocker_thread
	end

	# Ensure retry upon failure
	# Based on code from http://www.mongodb.org/display/DOCS/Replica+Pairs+in+Ruby
	def rescue_connection_failure
		success = false
		retries = 0
		while !success
			begin
				yield
				success = true
			rescue Mongo::ConnectionFailure => ex
				retries += 1
				raise ex if retries >= @retry_attempts
				sleep(@retry_delay)
			end
				end
		end
	
	def add pool, message
		raise NoSuchPool.new unless @pools.member? pool

		doc = {
			'message'			=> message,
			'locked'			 => false,
		}
		
		rescue_connection_failure do
			@database[pool].insert doc
		end
	end

	def acquire pool
		raise NoSuchPool.new unless @pools.member? pool
		now = Time.new.to_i
		doc = {}
		begin
			rescue_connection_failure do
				doc = @database[pool].find_and_modify(
					query: {
						'locked' => false
					},
					update: {
						'$set' => {
							'locked'			 => now,
							'locked_until' => now + @pools[pool][:timeout],
						},
					}
				)
			end
		rescue Mongo::OperationFailure => e
			raise EmptyPool
		end
		job = Job.new
		job.message = doc['message']
		job.id = doc['_id'].to_s
		job
	end

	def purge pool, id
		raise NoSuchPool.new unless @pools.member? pool
		rescue_connection_failure do
			@database[pool].remove _id: BSON::ObjectId(id)
		end
	end

	# fb303:
	def getName; 'jp'; end
	def getVersion; '0.0.1'; end
	def getStatus; Fb_status::ALIVE; end
	def getStatusDetails; 'nothing to see here; move along'; end
	def aliveSince; @start_time; end
	def shutdown
		STDERR.write "Shutdown requested via fb303\n"
		exit
	end
	# fb303 stubs:
	def setOption(key, value); end
	def getOption(key); end
	def getOptions; Hash.new; end
	def getCpuProfile(seconds); String.new; end
	def reinitialize; end
	# fb303 stubs properly implemented in JpInstrumentedServer:
	def getCounters; Hash.new; end
	def getCounter(name); 0; end
end
