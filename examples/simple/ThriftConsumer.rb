#!/usr/bin/env ruby
$LOAD_PATH.push '../../lib/rb/'
$LOAD_PATH.push '../gen-rb/'
require 'consumer'
require 'example_types'

c = Jp::ThriftConsumer.new 'thrift', ExampleData do |message|
	print "I consumed:\n%s\n" % message.inspect
	true # must return something that evalutes to true in a boolean context, or purge() isn't called.
end
c.run
