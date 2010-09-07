#!/usr/bin/env ruby
require 'producer'

require 'test/unit'
require 'mocha'

class TC_Jp_TextProducer < Test::Unit::TestCase
	def setup
		@test_message = rand(10000).to_s
		@test_pool    = rand(10000).to_s

		@jp = mock
		@p = Jp::TextProducer.new @test_pool, client: @jp
	end

	def test_add
		@jp.expects(:add).with(@test_pool, @test_message)
		
		@p.add @test_message
	end
end
