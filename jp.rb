#!/usr/bin/ruby
$LOAD_PATH.push File.dirname(__FILE__)
$LOAD_PATH.push File.dirname(__FILE__) + '/gen-rb/'

require 'jp-config'
require 'mongo'
require 'rev'

require 'job_pool'
include Jp

# Compatibility with Ruby 1.9.0
unless Encoding.respond_to? :default_internal
	def Encoding.default_internal
		nil
	end
end

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
	def initialize config
		# Setup Thrift server
		processor = JobPool::Processor.new self
		socket = Thrift::ServerSocket.new config.port_number
		transportFactory = Thrift::BufferedTransportFactory.new
		@server = Thrift::ThreadedServer.new processor, socket, transportFactory

		# Connect to mongodb
		@connection = Mongo::Connection.from_uri config.mongo_uri
		@database = @connection.db config.mongo_db

		@pools = Hash.new
		config.pools.each do |name, data|
			data[:timeout] ||= 3600 # Default to 1 hour
			data[:cleanup_interval] ||= data[:timeout]
			data[:purged] = Array.new
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
					to_purge, data[:purged] = data[:purged], Array.new
					pool.remove(
						_id: {'$in' => to_purge.map {|id| BSON::ObjectId(id) } }
					)
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
		@pools[pool][:purged].push id
	end
end

s = JpServer.new JpConfig.new
s.serve
