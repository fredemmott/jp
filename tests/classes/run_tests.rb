#!/usr/bin/env ruby

$LOAD_PATH.push File.dirname(__FILE__) + "/../../classes/"
$LOAD_PATH.push File.dirname(__FILE__) + "/../../lib/rb/"
$LOAD_PATH.push File.dirname(__FILE__)
require 'helpers'
require 'test/unit'

Dir.glob('./tc_*.rb').each do |testcase|
	require testcase
end
