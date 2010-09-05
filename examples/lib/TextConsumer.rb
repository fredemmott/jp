#!/usr/bin/env ruby
$LOAD_PATH.push '../../lib/rb'
require 'consumer'

c = Jp::TextConsumer.new 'text' do |message|
	print "I consumed a %s.\n" % message
	true # must return something that evalutes to true in a boolean context, or purge() isn't called.
end
c.run
