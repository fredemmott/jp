#!/usr/bin/env ruby
require 'producer'

require 'test/unit'
require 'mocha'

class TC_Jp_AbstractProducer < Test::Unit::TestCase
	def setup
		@test_message = rand(10000).to_s
		@test_pool    = rand(10000).to_s

		@jp = mock
		@p = Jp::AbstractProducer.new @test_pool, client: @jp
	end

	def test_add
		@p.expects(:translate).with(@test_message).returns(@test_message)
		@jp.expects(:add).with(@test_pool, @test_message)

		@p.add @test_message
	end

	def test_add_without_translate
		assert_raises NotImplementedError do
			@p.add @test_message
		end
	end
end
