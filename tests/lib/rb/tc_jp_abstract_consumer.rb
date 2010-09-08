#!/usr/bin/env ruby
require 'consumer'

require 'test/unit'
require 'mocha'

class TC_Jp_AbstractConsumer < Test::Unit::TestCase
	def setup
		@test_pool     = rand(10000).to_s
		@poll_interval = rand(10000)

		@test_job         = Jp::Job.new
		@test_job.id      = rand(10000).to_s 
		@test_job.message = rand(10000).to_s
		@test_job.freeze

		@block = mock

		@jp = mock
		@c = Jp::AbstractConsumer.new @test_pool, client: @jp, poll_interval: @poll_interval { @block.call }
	end

	def test_run
		# Override interval to zero (well, near enough)
		w = Rev::TimerWatcher.new Float::EPSILON, true
		Rev::TimerWatcher.expects(:new).with(@poll_interval, true).returns(w)
		
		# Let it poll 3 times, then throw an exception to stop it
		@c.expects(:poll).times(4).returns(nil).returns(nil).returns(nil).raises(Exception.new)
		
		assert_raises Exception do
			@c.run
		end
	end

	def test_consume_nil
		@block.expects(:call)

		@jp.expects(:acquire).with(@test_pool).returns(@test_job.dup)
		@c.expects(:translate).returns { |x| x }
		@c.send :consume
	end

	def test_consume_true
		@block.expects(:call).returns(true)

		@jp.expects(:acquire).with(@test_pool).returns(@test_job.dup)
		@jp.expects(:purge).with(@test_pool, @test_job.id)

		@c.expects(:translate).returns { |x| x }
		@c.send :consume
	end

	def test_consume_false
		@block.expects(:call).returns(false)

		@jp.expects(:acquire).with(@test_pool).returns(@test_job.dup)

		@c.expects(:translate).returns { |x| x }
		@c.send :consume
	end

	def test_consume_raise
		@block.expects(:call).raises(Exception.new)
		@jp.expects(:acquire).with(@test_pool).returns(@test_job.dup)
		@c.expects(:translate).returns { |x| x }
		assert_raises Exception do
			@c.send :consume
		end
	end

	def test_poll_consumes_until_empty
		# 3 calls are fine
		# 4th raises empty pool
		# poll should return the number of items consumed successfully
		@c.expects(:consume).times(4).returns(true).returns(true).returns(true).then.raises(Jp::EmptyPool.new)
		assert_equal 3, @c.poll
	end
end
