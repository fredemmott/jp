#!/usr/bin/env ruby
$LOAD_PATH.push File.dirname(__FILE__) + '/../gen-rb/'

require 'ruby-1.9.0-compat'
require 'mongo'
require 'rev'
require 'job_pool'
include Jp

class CallbackTimer < Rev::TimerWatcher
	def initialize interval, &block
		super interval, true
		@block = block
	end

	def on_timer
		@block.call
	end
end

class JpServer
	def initialize config, options = {}
		options[:default_timeout] ||= 3600 # 1 hour
		# Setup Thrift server (allowing dependency injection)
		if options.member? :thrift_server then
			@server = options[:thrift_server]
		else
			processor = JobPool::Processor.new self
			socket = Thrift::ServerSocket.new config.port_number
			transportFactory = Thrift::BufferedTransportFactory.new

			@server = Thrift::ThreadedServer.new processor, socket, transportFactory
		end

		# Connect to mongodb
		if options.member? :mongo_database then
			@database = options[:mongo_database]
		else
			connection = Mongo::Connection.from_uri config.mongo_uri
			@database = connection.db config.mongo_db
		end

		@pools = Hash.new
		config.pools.each do |name, data|
			data[:timeout] ||= options[:default_timeout]
			data[:cleanup_interval] ||= data[:timeout]
			@pools[name] = data
		end

	end

	def serve
		@start_time = Time.new
		# Look for expired entries
		Thread.new do
			l = Rev::Loop.new
			@pools.each do |name, data|
				pool = @database[name]
				w = CallbackTimer.new data[:cleanup_interval] {
					pool.update(
						{
							'locked_until' => { '$lte' => Time.new.to_i }
						},
						{
							'$set' => { 'locked' => false }
						},
						multi: true
					)
				}
				w.attach l
			end
			l.run
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
