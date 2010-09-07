module Jp
	class AbstractClient
		def initialize queue, options = {}
			raise NotImplementedError.new unless self.class != Jp::AbstractClient
			options[:host] ||= 'localhost'
			options[:port] ||= 9090
			options[:poll_interval] ||= 1
			@queue = queue
			@options = options

			if options[:client]
				@client = options[:client]
			else
				socket = Thrift::Socket.new options[:host], options[:port]
				transport = Thrift::BufferedTransport.new socket
				protocol = Thrift::BinaryProtocol.new transport
				@client = JobPool::Client.new protocol
				transport.open
			end
		end
	end
end
