#!/usr/bin/env ruby
# Test JpServer with all external dependencies mocked
# - doesn't require a mongodb server
# - doesn't start the Thrift server
require 'jp_instrumented_server'

require 'test/unit'
require 'mocha'

class TC_JpInstrumentedServer_Isolated < Test::Unit::TestCase
	def setup
		@server = mock
		@test_pool = rand(10000).to_s
		@test_message = rand(10000).to_s
		@jp = JpInstrumentedServer.new pools: {@test_pool => {}}, jp_server: @server
	end

	def test_pools
		assert_equal [@test_pool], @jp.pools
	end

	def test_counts_start_at_zero
		assert_equal 0, @jp.add_count(@test_pool)
		assert_equal 0, @jp.acquire_count(@test_pool)
		assert_equal 0, @jp.empty_count(@test_pool)
		assert_equal 0, @jp.purge_count(@test_pool)
	end

	def test_serves
		@server.expects(:serve)
		@jp.serve
	end

	def test_start_time_from_serve_not_initialize
		fake_time = Time.at(1337) # some time in 1970
		Time.expects(:new).returns(fake_time)
		@server.expects(:serve)
		@jp.serve
		assert_equal fake_time.to_i, @jp.start_time
	end

	def test_add
		assert_equal 0, @jp.add_count(@test_pool)
		@server.expects(:add).with(@test_pool,@test_message)
		@jp.add @test_pool, @test_message
		assert_equal 1, @jp.add_count(@test_pool)
	end

	def test_add_no_pool
		assert_equal 0, @jp.add_count(@test_pool)
		@server.expects(:add).raises(NoSuchPool.new)
		assert_raise NoSuchPool do
			@jp.add @test_pool, @test_message
		end
		assert_equal 0, @jp.add_count(@test_pool)
	end

	def test_acquire
		assert_equal 0, @jp.acquire_count(@test_pool)
		@server.expects(:acquire).with(@test_pool).returns(@test_message)

		assert_equal @test_message, @jp.acquire(@test_pool)

		assert_equal 1, @jp.acquire_count(@test_pool)
	end

	def test_acquire_no_pool
		assert_equal 0, @jp.acquire_count(@test_pool)
		assert_equal 0, @jp.empty_count(@test_pool)
		@server.expects(:acquire).with(@test_pool).raises(NoSuchPool.new)

		assert_raise NoSuchPool do
			@jp.acquire @test_pool
		end

		assert_equal 0, @jp.acquire_count(@test_pool)
		assert_equal 0, @jp.empty_count(@test_pool)
	end

	def test_acquire_empty_pool
		assert_equal 0, @jp.acquire_count(@test_pool)
		@server.expects(:acquire).with(@test_pool).raises(EmptyPool.new)

		assert_raise EmptyPool do
			@jp.acquire @test_pool
		end

		assert_equal 0, @jp.acquire_count(@test_pool)
		assert_equal 1, @jp.empty_count(@test_pool)
	end

	def test_purge
		assert_equal 0, @jp.purge_count(@test_pool)
		@server.expects(:purge).with(@test_pool, @test_message)
		@jp.purge @test_pool, @test_message
		assert_equal 1, @jp.purge_count(@test_pool)
	end

	def test_purge_no_pool
		assert_equal 0, @jp.purge_count(@test_pool)
		@server.expects(:purge).raises(NoSuchPool.new)

		assert_raise NoSuchPool do
			@jp.purge @test_pool, @test_message
		end

		assert_equal 0, @jp.purge_count(@test_pool)
	end

	def test_add_count_no_pool
		assert_raise NoSuchPool do
			@jp.add_count 'no_such_pool'
		end
	end

	def test_acquire_count_no_pool
		assert_raise NoSuchPool do
			@jp.acquire_count 'no_such_pool'
		end
	end

	def test_empty_count_no_pool
		assert_raise NoSuchPool do
			@jp.empty_count 'no_such_pool'
		end
	end

	def test_purge_count_no_pool
		assert_raise NoSuchPool do
			@jp.purge_count 'no_such_pool'
		end
	end
end
