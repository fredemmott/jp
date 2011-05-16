#!/usr/bin/env ruby
require 'jp/server/unlocker'

require 'test/unit'
require 'mocha'

class TC_JpUnlocker_Isolated < Test::Unit::TestCase
	include JpTestHelpers
	def setup
		@mongo = mock
		@mongo.stubs(:[]).returns(mock)

		@default_timeout = rand 1000
		@unlocker = Jp::Server::Unlocker.new(
			{
				:injected_mongo_database  => @mongo,
				:default_timeout          => @default_timeout,
				:mongo_db                 => 'test_db',
				:pools                    => {'test_pool' => {}},
			}
		)
	end

	def test_clean_no_pool
		assert_raise Jp::NoSuchPool do
			@unlocker.clean 'no_such_pool'
		end
	end

	def test_clean
		# Remove race condition when checking the message
		now = Time.new
		Time.expects(:new).returns(now)

		mongo_pool do |pool|
			pool.expects(:update).with do |query, update, options|
				assert query['locked_until'], 'query compares locked_until'
				assert query['locked_until']['$lte'], 'query uses less than or equal'
				assert_equal now.to_i, query['locked_until']['$lte'], 'query uses correct time stamp'

				assert options[:multi], 'has multi option set'

				assert update['$set'], 'update sets a value'
				assert update['$set'].member?('locked'), 'update sets locked'
				assert_equal false, update['$set']['locked'], 'update sets locked to false'

				true
			end
		end
		@unlocker.clean 'test_pool'
	end

	def test_run_starts_event_loop
		l = Rev::Loop.new
		Rev::Loop.expects(:new).returns(l)
		l.expects(:run)

		@unlocker.run
	end

	def test_run_calls_clean_on_timer
		# Make the timer repeat [near] instantly
		t = Rev::TimerWatcher.new Float::EPSILON, true
		Rev::TimerWatcher.expects(:new).with(@default_timeout, true).returns(t)

		# Make sure that 'clean' is called until we throw an exception to get out of it
		@unlocker.expects(:clean).with('test_pool').times(4).returns(nil).returns(nil).returns(nil).raises(Exception.new)

		# Run the test
		assert_raises Exception do
			@unlocker.run
		end
	end
end
