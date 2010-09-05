#!/usr/bin/env ruby

$LOAD_PATH.push File.dirname(__FILE__) + '/../../gen-rb/'
require 'jp'

socket = Thrift::Socket.new 'localhost', 9090
transport = Thrift::BufferedTransport.new socket
protocol = Thrift::BinaryProtocol.new transport
client = Jp::Client.new protocol
transport.open

print "Adding a pie...\n"
client.add 'text', 'pie'
print "I added a pie.\n"
