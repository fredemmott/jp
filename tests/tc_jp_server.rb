#!/usr/bin/env ruby
require 'test/unit'
require 'mocha'
require 'jp_server'

class TC_JpServer < Test::Unit::TestCase
	def setup
		@thrift = mock
		@mongo = mock
		@config = mock
		@config.stubs(:pools).returns({'test_pool' => {}})
		@mongo.stubs(:[]).returns(mock)

		@default_timeout = rand 1000

		@jp = JpServer.new @config, thrift_server: @thrift, mongo_database: @mongo, default_timeout: @default_timeout
	end

	def test_starts_thrift_server
		@thrift.expects(:serve)
		@jp.serve
	end

	def test_add message = 'foo'
		pool = mock
		pool.expects(:insert).with { |doc| doc['message'] == message && doc['locked'] == false }

		@mongo.expects(:[]).with('test_pool').returns(pool)
		@jp.add 'test_pool', message
	end

	def test_add_no_pool
		assert_raise NoSuchPool do
			@jp.add 'no_such_pool', 'foo'
		end
	end

	def test_acquire
		test_message = rand(10000).to_s
		test_id = rand 10000
		# Mock the Timer so we can compare it
		now = Time.new
		Time.expects(:new).returns(now)

		# Check it boils down to a correct find-and-modify
		pool = mock
		pool.expects(:find_and_modify).with{ |p| p[:query].member? 'locked' }.with{ |p| !p[:query]['locked'] }.with{ |p|
			p[:update]['$set']['locked'] == now.to_i }.with{ |p| p[:update]['$set']['locked_until'] == now.to_i + @default_timeout
			}.returns(
				'message' => test_message,
				'_id'     => test_id
			)
		# Give the mock pool to the mock mongo
		@mongo.expects(:[]).with('test_pool').returns(pool)

		# Try calling
		job = @jp.acquire 'test_pool'

		# Check we got back the appropriate data
		assert_equal test_message, job.message
		assert_equal test_id.to_s, job.id
	end

	def test_acquire_no_pool
		assert_raise NoSuchPool do
			@jp.acquire 'no_such_pool'
		end
	end
end
