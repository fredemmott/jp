#!/usr/bin/env ruby
# Find a config file and load it
module Jp
	def self.load_server_config
		load config_file 'jp-config'
		c = JpConfig.new
		def c.options
			m = self.public_methods - Object.public_methods - [:options]
			h = Hash.new
			m.each do |method|
				h[method] = self.send method
			end
			h
		end
		c.options
	end

	def self.load_mapper_config
		load config_file 'jp-mapper-config'
		JpMapperConfig.new
	end

	private
	def self.config_file name
		if ARGV[0] && File.exists?(ARGV[0])
			return File.expand_path ARGV[0]
		end

		# Prefixes
		[
			'./',
			'~/',
			'~/.',
			'/etc/',
		].each do |prefix|
			full = File.expand_path "%s%s.rb" % [prefix, name]
			if File.exists? full
				return full
			end
		end
		raise 'No config file found.'
	end
end
