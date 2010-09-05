#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../gen-rb/'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/./gen-rb/'
require 'job_pool'
require_relative './client.rb'

autoload :Rev, 'rev'

module Jp
	class AbstractConsumer < AbstractClient
		def initialize queue, options = {}, &block
			raise NotImplementedError.new unless self.class != Jp::AbstractConsumer
			super queue, options
			@block = block
		end

		def run
			worker = Rev::TimerWatcher.new @options[:poll_interval], true
			def worker.block= block
				@block = block
			end
			def worker.on_timer
				@block.call
			end
			worker.block = lambda do
				poll
			end
			rev_loop = Rev::Loop.new
			worker.attach rev_loop
			rev_loop.run
		end

		def poll
			i = 0
			begin
				loop do
					consume
					i += 1
				end
			rescue EmptyPool
				return i
			end
		end

		private

		def consume
			job = @client.acquire @queue
			@client.purge @queue, job.id if @block.call(translate job.message)
		end

		def translate message
			raise NotImplementedError.new
		end
	end

	class TextConsumer < AbstractConsumer
		private
		def translate message
			message
		end
	end
end
