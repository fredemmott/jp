#!/usr/bin/env ruby

$LOAD_PATH.push File.dirname(__FILE__) + '/../../gen-rb/'
require 'job_pool'
include Jp

socket = Thrift::Socket.new 'localhost', 9090
transport = Thrift::BufferedTransport.new socket
protocol = Thrift::BinaryProtocol.new transport
client = JobPool::Client.new protocol
transport.open

loop do
	begin
		job = client.acquire 'text'
		print "I'm consuming a %s.\n" % job.message
		client.purge 'text', job.id
		print "I consumed a %s.\n" % job.message
	rescue EmptyPool
		print "Pool is empty :(\n"
		break
	end
end
