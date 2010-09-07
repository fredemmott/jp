#!/usr/bin/env ruby
require 'test/unit'
require 'mocha'
require 'jp_server'


class TC_JpServer_Isolated < Test::Unit::TestCase
	def setup
		@thrift = mock
		@mongo = mock
		@config = mock
		@config.stubs(:pools).returns({'test_pool' => {}})
		@mongo.stubs(:[]).returns(mock)

		@default_timeout = rand 1000

		@jp = JpServer.new @config, thrift_server: @thrift, mongo_database: @mongo, default_timeout: @default_timeout
	end

	def mongo_pool
		pool = mock
		yield pool
		@mongo.expects(:[]).with('test_pool').returns(pool)
	end

	def test_starts_thrift_server
		@thrift.expects(:serve)
		@jp.serve
	end

	def test_add
		message = rand(10000).to_s
		mongo_pool do |pool|
			pool.expects(:insert).with do |p|
				assert_equal message, p['message']
				assert_equal false, p['locked']
				true
			end
		end

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
		mongo_pool do |pool|
			pool.expects(:find_and_modify).with do |p|
				assert p[:query].member?('locked'), 'has locked field'
				assert !p[:query]['locked'], 'is not locked'
				assert_equal now.to_i + @default_timeout, p[:update]['$set']['locked_until']
				true
			end.returns(
				'message' => test_message,
				'_id'     => test_id
			)
		end

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

	def test_acquire_empty_pool
		mongo_pool { |pool| pool.expects(:find_and_modify).raises(Mongo::OperationFailure) }
		assert_raise Jp::EmptyPool do
			@jp.acquire 'test_pool'
		end
	end
end
