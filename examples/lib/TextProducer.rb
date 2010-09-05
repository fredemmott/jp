#!/usr/bin/env ruby
$LOAD_PATH.push '../../lib/rb'
require 'producer'

p = Jp::TextProducer.new 'text'
p.add 'simple pie'
