#!/usr/bin/ruby
require 'jp-config'
require 'mongo'

$LOAD_PATH.push File.dirname(__FILE__) + '/gen-rb/'
require 'gen-rb/jp'

class JpServer
	def initialize config
		# Setup Thrift server
		processor = Jp::Processor.new self
		socket = Thrift::ServerSocket.new config.port_number
		transportFactory = Thrift::BufferedTransportFactory.new
		@server = Thrift::ThreadedServer.new processor, socket, transportFactory

		# Connect to mongodb
		@connection = Mongo::Connection.from_uri config.mongo_uri
		@database = @connection.db config.mongo_db

		@pools = Hash.new
		config.pools.each do |name, data|
			data[:timeout] ||= 3600 # Default to 1 hour
			@pools[name] = data
		end
	end

	def serve
		@start_time = Time.new
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
			p e
			p "Assuming it's an empty pool error"
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

s = JpServer.new JpConfig.new
s.serve
