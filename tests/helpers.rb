#!/usr/bin/env ruby
module JpTestHelpers
	def mongo_pool
		pool = mock
		yield pool
		@mongo.expects(:[]).with('test_pool').returns(pool)
	end
end
