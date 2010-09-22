#!/usr/bin/env ruby
$LOAD_PATH.push File.dirname(__FILE__) + '/../gen-rb/'

require 'job_pool_instrumented'
require 'ruby-1.9.0-compat'

include Jp

class JpMapper
	def initialize config, options = {}
		if config.respond_to? :port_number
			port_number = config.port_number
		end
		port_number ||= 9090
		raise ArgumentError.new "config object doesn't provide mapping" unless config.respond_to? :host_for_pool
		@config = config

		# Setup Thrift server (allowing dependency injection)
		if options.member? :injected_thrift_server then
			@server = options[:injected_thrift_server]
		else
			processor = options[:thrift_processor] # For testing, and allow instrumented server to override
			processor ||= JobPool::Processor.new self
			socket = Thrift::ServerSocket.new port_number
			transportFactory = Thrift::BufferedTransportFactory.new

			@server = Thrift::ThreadedServer.new processor, socket, transportFactory
		end
	end

	def serve
		@server.serve
	end
	
	def add pool, message
		upstream_for_pool(pool).add(pool, message)
	end

	def acquire pool
		upstream_for_pool(pool).acquire(pool)
	end

	def purge pool, id
		upstream_for_pool(pool).purge(pool, id)
	end

	private
	def upstream_for_pool pool
		@clients ||= Hash.new
		upstream = @config.host_for_pool pool

		# Well... in practise, you'll want to specify one or the other ;)
		upstream[:host] ||= 'localhost'
		upstream[:port] ||= 9090

		unless @clients.member? upstream
			socket = Thrift::Socket.new upstream[:host], upstream[:port]
			transport = Thrift::BufferedTransport.new socket
			protocol = Thrift::BinaryProtocol.new transport
			client = JobPool::Client.new protocol
			@clients[upstream] = client
		end
		@clients[upstream]
	end
end
