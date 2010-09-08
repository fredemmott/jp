#!/usr/bin/env ruby
$LOAD_PATH.push File.dirname(__FILE__)
require 'jp_server'
require 'job_pool_instrumented'

class JpInstrumentedServer < JpServer
	def initialize options = {}
		super options
		@add_count = Hash.new 0
		@acquire_count = Hash.new 0
		@purge_count = Hash.new 0
	end

	# Readers

	def start_time
		@start_time
	end

	def pools
		@pools.keys
	end

	def add_count pool
		raise Jp::NoSuchPool.new unless @pools.member? pool
		@add_count[pool]
	end

	def acquire_count pool
		raise Jp::NoSuchPool.new unless @pools.member? pool
		@acquire_count[pool]
	end

	def purge_count pool
		raise Jp::NoSuchPool.new unless @pools.member? pool
		@purge_count[pool]
	end

	# Data collectors

	def serve
		@start_time = Time.new.to_i
		super
	end

	def add pool, message
		result = super pool, message
		@add_count[pool] += 1
		result
	end

	def acquire pool
		result = super pool
		@acquire_count[pool] += 1
		result
	end

	def purge pool, id
		result = super pool, id
		@purge_count[pool] += 1
		result
	end

	private
	def thrift_processor
		JobPoolInstrumented::Processor.new self
	end
end
