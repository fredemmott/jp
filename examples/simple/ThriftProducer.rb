#!/usr/bin/env ruby
$LOAD_PATH.push '../../lib/rb'
$LOAD_PATH.push '../gen-rb/'
require 'producer'
require 'example_types'

p = Jp::ThriftProducer.new 'thrift'
doc = ExampleData.new language: 'ruby', api: 'simple', format: 'thrift'
p.add doc
