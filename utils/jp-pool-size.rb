#!/usr/bin/env ruby

$LOAD_PATH.push File.dirname(__FILE__) + '/../classes/'

require 'ruby-1.9.0-compat'
require 'jp_config_loader'
require 'mongo'


module Jp
	def self.pool_sizes
		# Load options & defaults
		options = Jp::load_server_config

		options[:mongo_uri] ||= 'mongodb://localhost'
		raise ArgumentError.new "mongo_db option must be specified" unless options[:mongo_db]
		raise ArgumentError.new "pools option must be specified" unless options[:pools]
		raise ArgumentError.new "pools option must not be empty" unless ! options[:pools].empty?

		# Connect to mongodb
		connection = Mongo::Connection.from_uri options[:mongo_uri]
		database = connection.db options[:mongo_db]

		out = Hash.new
		options[:pools].each do |name, data|
			out[name] = database[name].count
		end
		out
	end
end

if File.expand_path($0) == File.expand_path(__FILE__)
	Jp.pool_sizes.each do |name, size|
		next if ARGV[0] && ARGV[0] != name
		print "%s: %d\n" % [name, size]
	end
end
