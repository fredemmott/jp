#!/usr/bin/env ruby
require 'producer'

require 'test/unit'
require 'mocha'

# Load struct defined in examples/example.thrift
$LOAD_PATH.push File.dirname(__FILE__) + '/../../../examples/gen-rb/'
require 'example_types'

class TC_Jp_ThriftProducer < Test::Unit::TestCase
	def setup
		@test_pool    = rand(10000).to_s
		@test_message = ExampleData.new(
			{
				:language => rand(10000).to_s,
				:api      => rand(10000).to_s,
				:format   => rand(10000).to_s,
			}
		)

		@jp = mock
		@p = Jp::ThriftProducer.new @test_pool, client: @jp
	end

	def test_add
		@jp.expects(:add).with do |pool,bytes|
			# Check the pool name
			assert_equal @test_pool, pool, 'pool matches'

			# Thrift binary -> struct
			message = ExampleData.new
			Thrift::Deserializer.new.deserialize message, bytes

			# Compare the original and asserted struct
			assert_equal @test_message, message, 'message matches'
			true
		end
		
		@p.add @test_message
	end
end
