#!/usr/bin/env ruby
# Unlock pool entries that have been lcoked for longer than the timer
require 'jp/thrift'
require 'ruby-1.9.0-compat'

require 'mongo'
require 'rev'

class JpUnlocker
	def initialize options = {}
		options[:default_timeout] ||= 3600 # 1 hour
		options[:mongo_uri] ||= 'mongodb://localhost'
		raise ArgumentError.new "mongo_db option must be specified" unless options[:mongo_db]
		raise ArgumentError.new "pools option must be specified" unless options[:pools]
		raise ArgumentError.new "pools option must not be empty" unless ! options[:pools].empty?

		# Connect to mongodb
		if options.member? :injected_mongo_database then
			@database = options[:injected_mongo_database]
		else
			connection = Mongo::Connection.from_uri options[:mongo_uri]
			@database = connection.db options[:mongo_db]
		end

		@pools = Hash.new
		options[:pools].each do |name, data|
			data[:timeout] ||= options[:default_timeout]
			data[:cleanup_interval] ||= data[:timeout]
			@pools[name] = data
		end
	end

	def clean pool_name
		raise Jp::NoSuchPool unless @pools.member? pool_name
		@database[pool_name].update(
			{
				'locked_until' => { '$lte' => Time.new.to_i }
			},
			{
				'$set' => { 'locked' => false }
			},
			multi: true
		)
	end

	def run
		l = Rev::Loop.new
		@pools.each do |name, data|
			t = Rev::TimerWatcher.new data[:cleanup_interval], true
			def t.on_timer &block
				if block_given?
					@block = block
				else
					@block.call
				end
			end
			t.on_timer { clean name }
			t.attach l
		end
		l.run
	end
end
