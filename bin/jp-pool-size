#!/usr/bin/env ruby

$LOAD_PATH.push File.dirname(__FILE__) + '/../lib/rb/'

require 'jp/server/configuration_loader'
require 'jp/server/handler'
require 'mongo'


module Jp
	def self.pool_sizes
		options = Jp::Server::ConfigurationLoader.server_config
    server = Jp::Server::Handler.new(options)

		out = Hash.new
		server.pools.each do |name, data|
			out[name] = server.database[name].count
		end
		out
	end
end

if File.expand_path($0) == File.expand_path(__FILE__)
	Jp.pool_sizes.each do |name, size|
		print "%s: %d\n" % [name, size]
	end
end
