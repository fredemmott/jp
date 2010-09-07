#!/usr/bin/env ruby
# Find a config file and load it
module Jp
	def self.load_config
		# Where we look for config files
		[
			ARGV[0],
			'./jp-config.rb',
			'~/jp-config.rb',
			'~/.jp-config.rb',
			'/etc/jp-config.rb',
		].each do |path|
			next unless path
			full = File.expand_path path
			if File.exists? full
				load full
				c = JpConfig.new
				def c.options
					m = self.public_methods - Object.public_methods - [:options]
					h = Hash.new
					m.each do |method|
						h[method] = self.send method
					end
					h
				end
				return c.options
				break
			end
			raise 'No config file found.'
		end
	end
end
