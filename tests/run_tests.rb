#!/usr/bin/ruby1.9
$LOAD_PATH.push File.dirname(__FILE__) + "/../classes/"
$LOAD_PATH.push File.dirname(__FILE__)
require 'helpers'
require 'test/unit'

Dir.glob('./tc_*.rb').each do |testcase|
	require testcase
end
