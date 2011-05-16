#!/usr/bin/env ruby

require 'jp/client'

autoload :Rev, 'rev'
autoload :JSON, 'json'

module Jp
	class AbstractConsumer < AbstractClient
		def initialize queue, options = {}, &block
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

	class JsonConsumer < AbstractConsumer
		private
		def translate message
			JSON::load message
		end
	end

	class ThriftConsumer < AbstractConsumer
		def initialize queue, base, options = {}, &block
			super queue, options, &block
			@base = base
			@deserializer = Thrift::Deserializer.new
		end
		private
		def translate message
			struct = @base.new
			@deserializer.deserialize struct, message
			struct
		end
	end
end
