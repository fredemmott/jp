#!/usr/bin/env ruby
require 'consumer'

require 'test/unit'
require 'mocha'

# Load struct defined in examples/example.thrift
$LOAD_PATH.push File.dirname(__FILE__) + '/../../../examples/gen-rb/'
require 'example_types'

class TC_Jp_ThriftConsumer < Test::Unit::TestCase
	def setup
		@test_pool = rand(10000).to_s
		@jp = mock
		@c = Jp::ThriftConsumer.new @test_pool, ExampleData, client: @jp {}
	end

	def test_translate
		# Test input data
		in_struct = ExampleData.new(
			{
				:language => rand(10000).to_s,
				:api      => rand(10000).to_s,
				:format   => rand(10000).to_s,
			}
		).freeze
		in_blob = Thrift::Serializer.new.serialize(in_struct).freeze

		# Get the output in the same format
		out_struct = @c.send(:translate, in_blob).freeze
		out_blob = Thrift::Serializer.new.serialize(out_struct).freeze
		
		# Compare
		assert_equal in_struct, out_struct, 'structs match'
		assert_equal in_blob, out_blob, 'blobs match'
	end
end
