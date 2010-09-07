#!/usr/bin/env ruby
$LOAD_PATH.push File.dirname(__FILE__) + '/../gen-rb/'

require 'jp_unlocker'
require 'job_pool'
require 'ruby-1.9.0-compat'

require 'mongo'
include Jp

class JpServer
	def initialize options = {}
		options[:default_timeout] ||= 3600 # 1 hour
		options[:port_number] ||= 9090
		options[:mongo_uri] ||= 'mongodb://localhost'
		raise ArgumentError.new "mongo_db option must be specified" unless options[:mongo_db]
		raise ArgumentError.new "pools option must be specified" unless options[:pools]
		raise ArgumentError.new "pools option must not be empty" unless ! options[:pools].empty?

		# Setup Thrift server (allowing dependency injection)
		if options.member? :injected_thrift_server then
			@server = options[:injected_thrift_server]
		else
			processor = JobPool::Processor.new self
			socket = Thrift::ServerSocket.new options[:port_number]
			transportFactory = Thrift::BufferedTransportFactory.new

			@server = Thrift::ThreadedServer.new processor, socket, transportFactory
		end

		# Connect to mongodb
		if options.member? :injected_mongo_database then
			@database = options[:injected_mongo_database]
		else
			connection = Mongo::Connection.from_uri options[:mongo_uri]
			@database = connection.db options[:mongo_db]
		end

		@pools = Hash.new
		options[:pools].each do |name, data|
			data[:timeout] ||= options[:default_timeout]
			data[:cleanup_interval] ||= data[:timeout]
			@pools[name] = data
		end

		@unlocker = JpUnlocker.new options unless options[:skip_embedded_unlocker]
	end

	def serve
		@start_time = Time.new
		# Look for expired entries
		@unlocker ||= nil
		if @unlocker then
			Thread.new do
				@unlocker.run
			end
		end
		@server.serve
	end
	
	def add pool, message
		raise NoSuchPool.new unless @pools.member? pool

		doc = {
			'message'      => message,
			'enqueue_time' => Time.new.to_i,
			'locked'       => false,
		}

		@database[pool].insert doc
	end

	def acquire pool
		raise NoSuchPool.new unless @pools.member? pool
		now = Time.new.to_i
		begin
			doc = @database[pool].find_and_modify(
				query: {
					'locked' => false
				},
				update: {
					'$set' => {
						'locked'       => now,
						'locked_until' => now + @pools[pool][:timeout],
					},
				}
			)
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
		@database[pool].remove _id: BSON::ObjectId(id)
	end
end
