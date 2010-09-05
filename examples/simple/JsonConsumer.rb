#!/usr/bin/env ruby
$LOAD_PATH.push '../../lib/rb'
require 'consumer'

c = Jp::JsonConsumer.new 'json' do |message|
	print "I consumed:\n%s\n" % message.inspect
	true # must return something that evalutes to true in a boolean context, or purge() isn't called.
end
c.run
