#!/usr/bin/env ruby

$LOAD_PATH.push File.dirname(__FILE__) + '/../gen-rb/'
require 'job_pool'
include Jp

THREAD_COUNT=10
PER_THREAD=1000
TOTAL=THREAD_COUNT * PER_THREAD

threads = Array.new

start = Time.new

(1..THREAD_COUNT).each do
	thread = Thread.new do
		socket = Thrift::Socket.new 'localhost', 9090
		transport = Thrift::BufferedTransport.new socket
		protocol = Thrift::BinaryProtocol.new transport
		client = JobPool::Client.new protocol
		transport.open
	
		(1..PER_THREAD).each do
			job = client.acquire 'text'
			client.purge 'text', job.id
		end
	end
	threads.push thread
end

threads.each { |thread| thread.join }

finished = Time.new
elapsed = finished - start
print <<EOF
Started:    #{start.to_s}
Finished:   #{finished.to_s}
Elapsed:    #{elapsed}s
Threads:    #{THREAD_COUNT}
Consumed:   #{TOTAL}
per thread: #{PER_THREAD}
per second: #{TOTAL / elapsed.to_f}
EOF
