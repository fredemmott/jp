#!/usr/bin/env ruby
require 'jp/producer'

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
		@jp.expects(:add).with do |pool,blob|
			# Check the pool name
			assert_equal @test_pool, pool, 'pool matches'

			# Deserialize the blob, and check it matches our original struct
			message = ExampleData.new
			Thrift::Deserializer.new.deserialize message, blob 
			assert_equal @test_message, message, 'structs match'

			# Serialize our struct, and make sure it matches the new blob
			assert_equal Thrift::Serializer.new.serialize(@test_message), blob, 'blobs match'
			true
		end
		
		@p.add @test_message
	end
end
