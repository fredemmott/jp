#!/usr/bin/env ruby1.9
# Requires:
# - Thrift

module Jp
	def self.stats host, port
		##### Thrift setup #####

		$LOAD_PATH.push File.dirname(__FILE__) + '/../gen-rb/'
		require 'job_pool_instrumented'

		transport = Thrift::BufferedTransport.new(Thrift::Socket.new(host, port))
		client = JobPoolInstrumented::Client.new(Thrift::BinaryProtocol.new(transport))
		transport.open

		##### Our code #####

		# We're connected, get the stats
		start_time = client.start_time
		pools      = client.pools

		added      = Hash.new(0)
		acquired   = Hash.new(0)
		empty      = Hash.new(0)
		purged     = Hash.new(0)

		pools.each do |pool|
			added[pool]    = client.add_count pool
			acquired[pool] = client.acquire_count pool
			empty[pool]    = client.empty_count pool
			purged[pool]   = client.purge_count pool

			added[:total]    += added[pool]
			acquired[:total] += acquired[pool]
			empty[:total]    += empty[pool]
			purged[:total]   += purged[pool]
		end
		{
			added:      added,
			acquired:   acquired,
			empty:      empty,
			purged:     purged,
			start_time: start_time,
			pools:      pools,
		}
	end
end

if File.expand_path($0) == File.expand_path(__FILE__)
	target = ARGV[0]
	target ||= 'localhost:9090'
	host, port = target.split(':')

	result = Jp.stats host, port

	added    = result[:added]
	acquired = result[:acquired]
	empty    = result[:empty]
	purged   = result[:purged]

	start_time = result[:start_time]
	seconds = (Time.now.to_i - start_time)
	pools = result[:pools]

	print <<EOF
#################
##### TOTAL #####
#################
running_since: #{start_time} (#{Time.at start_time})
running_for:   #{seconds} seconds
pools:         #{pools.size}
added:         #{added[:total]} (#{added[:total].to_f / seconds}/s)
acquired:      #{acquired[:total]} (#{acquired[:total].to_f / seconds}/s)
empty:         #{empty[:total]} (#{empty[:total].to_f / seconds}/s)
purged:        #{purged[:total]} (#{purged[:total].to_f / seconds}/s)
EOF

	pools.each do |pool|
		print ("#" * (12 + pool.length)) + "\n"
		print "##### %s #####\n" % pool
		print ("#" * (12 + pool.length)) + "\n"
		print "added:    %d (%f/s)\n" % [added[pool], added[pool].to_f / seconds]
		print "acquired: %d (%f/s)\n" % [acquired[pool], acquired[pool].to_f / seconds]
		print "empty:    %d (%f/s)\n" % [empty[pool], empty[pool].to_f / seconds]
		print "purged:   %d (%f/s)\n" % [purged[pool], purged[pool].to_f / seconds]
	end
end
