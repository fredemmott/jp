#!/usr/bin/env ruby
$LOAD_PATH.push File.dirname(__FILE__)
require 'jp_server'
require 'job_pool_instrumented'

class JpInstrumentedServer < JpServer
	def initialize options = {}
		options[:jp_server] ||= JpServer.new options.merge(thrift_processor: JobPoolInstrumented::Processor.new(self))
		@server = options[:jp_server]
		@pools = options[:pools].keys
		@add_count = Hash.new 0
		@acquire_count = Hash.new 0
		@purge_count = Hash.new 0
		@empty_count = Hash.new 0
	end

	# Readers

	def start_time
		@server.aliveSince
	end

	def pools
		@pools
	end

	def add_count pool
		raise Jp::NoSuchPool.new unless @pools.include? pool
		@add_count[pool]
	end

	def acquire_count pool
		raise Jp::NoSuchPool.new unless @pools.include? pool
		@acquire_count[pool]
	end

	def empty_count pool
		raise Jp::NoSuchPool.new unless @pools.include? pool
		@empty_count[pool]
	end

	def purge_count pool
		raise Jp::NoSuchPool.new unless @pools.include? pool
		@purge_count[pool]
	end

	# Data collectors

	def serve
		@server.serve
	end

	def add pool, message
		result = @server.add pool, message
		@add_count[pool] += 1
		result
	end

	def acquire pool
		begin
			result = @server.acquire pool
			@acquire_count[pool] += 1
		rescue EmptyPool => e
			@empty_count[pool] += 1
			raise e
		end
		result
	end

	def purge pool, id
		result = @server.purge pool, id
		@purge_count[pool] += 1
		result
	end

	def getCounters
		counters = Hash.new
		pools.each do |pool|
			counters["#{pool}.added"]    = add_count(pool)
			counters["#{pool}.acquired"] = acquire_count(pool)
			counters["#{pool}.empty"]    = empty_count(pool)
			counters["#{pool}.purged"]   = purge_count(pool)
		end
		counters
	end
end
