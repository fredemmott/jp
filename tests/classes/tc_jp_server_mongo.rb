#!/usr/bin/env ruby
# Test Jp::Server::Server against the local mongo db server
# - requires a running mongodb server
# - doesn't start the Thrift server
require 'jp/server/server'

require 'mongo'

require 'test/unit'
require 'mocha'

class TC_JpServer_Mongo < Test::Unit::TestCase
	def setup
		@test_message = 'test message %d' % rand(100000)

		@thrift = mock
		@unlocker = mock

		@default_timeout = rand 1000

		conn = Mongo::Connection.new
		db = conn.db('jp_autotest')
		@pool = db['test_pool']
		@pool.remove

		assert_equal 0, @pool.count, 'collection is empty before starting jp'

		@jp = Jp::Server::Server.new(
			{
				:injected_thrift_server  => @thrift,
				:injected_mongo_database => db,
				:mongo_db                => 'jp_autotest',
				:default_timeout         => @default_timeout,
				:pools                   => {'test_pool' => {}},
				:skip_embedded_unlocker  => true,
			}
		)

		assert_equal 0, @pool.count, 'collection is empty after starting jp'
	end

	def test_add_no_pool
		test_message = rand(10000).to_s
		assert_raises Jp::NoSuchPool do
			@jp.add 'no_such_pool', test_message
		end
		assert_equal 0, @pool.count, 'collection is empty'
	end

	def test_add
		assert_equal 0, @pool.count, 'collection is empty'
		@jp.add 'test_pool', @test_message
		assert_equal 1, @pool.count, 'collection has item'
	end

	def test_acquire_no_pool
		assert_raises Jp::NoSuchPool do
			@jp.acquire 'no_such_pool'
		end
	end

	def test_acquire_empty
		assert_raises Jp::EmptyPool do
			@jp.acquire 'test_pool'
		end
	end

	def test_acquire
		test_add
		assert_equal 1, @pool.count, 'have item to acquire'
		job = @jp.acquire 'test_pool'
		assert_equal @test_message, job.message
		assert_equal 1, @pool.count, 'item still in pool'
		job
	end

	def test_acquire_then_empty
		test_acquire
		assert_equal 1, @pool.count, 'item still in pool'
		assert_raises Jp::EmptyPool do
			@jp.acquire 'test_pool'
		end
		assert_equal 1, @pool.count, 'item still after second acquire'
	end

	def test_purge_after_acquire
		job = test_acquire
		assert_equal 1, @pool.count, 'item in pool before purge'
		@jp.purge 'test_pool', job.id
		assert_equal 0, @pool.count, 'item purged from pool'
	end

	def test_purge_no_pool
		assert_raises Jp::NoSuchPool do
			@jp.acquire 'no_such_pool'
		end
	end

	def test_purge_invalid_id
		job = test_acquire
		assert_equal 1, @pool.count, 'item in pool before purge'
		@jp.purge 'test_pool', job.id.succ
		assert_equal 1, @pool.count, 'item in pool after purge'
	end

	def test_purge_twice
		job = test_acquire
		assert_equal 1, @pool.count, 'item in pool before purge'
		@jp.purge 'test_pool', job.id
		assert_equal 0, @pool.count, 'item in pool before purge'
		@jp.purge 'test_pool', job.id # Just checking there's no exceptions
	end
end
