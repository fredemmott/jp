# Unlock pool entries that have been lcoked for longer than the timer
require 'jp/thrift'
require 'jp/server/mongo_connection'
require 'jp/server/pools'

require 'mongo'
require 'rev'

module Jp
  module Server
    class Unlocker
      include MongoConnection
      include Pools
    	def initialize options = {}
        load_pools(options)
        connect_to_mongo(options)
    	end
    
    	def clean pool_name
    		raise Jp::NoSuchPool unless @pools.member? pool_name
    		@database[pool_name].update(
    			{
    				'locked_until' => { '$lte' => Time.new.to_i }
    			},
    			{
    				'$set' => { 'locked' => false }
    			},
    			multi: true
    		)
    	end
    
    	def run
    		l = Rev::Loop.new
    		@pools.each do |name, data|
    			t = Rev::TimerWatcher.new data[:cleanup_interval], true
    			def t.on_timer &block
    				if block_given?
    					@block = block
    				else
    					@block.call
    				end
    			end
    			t.on_timer { clean name }
    			t.attach l
    		end
    		l.run
    	end
    end
  end
end
