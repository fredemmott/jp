#!/usr/bin/env ruby
$LOAD_PATH.push File.dirname(__FILE__)
require 'jp-config'
require 'jp_server'

s = JpServer.new JpConfig.new
s.serve
