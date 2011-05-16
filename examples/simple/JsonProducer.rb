#!/usr/bin/env ruby
$LOAD_PATH.push '../../lib/rb'
require 'jp/producer'

p = Jp::JsonProducer.new 'json'
doc = {
	'language' => 'ruby',
	'api'      => 'simple',
	'format'   => 'json',
}
p.add doc
