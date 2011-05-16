#!/usr/bin/env ruby

autoload :YAML, 'yaml'

# Find a config file and load it
module Jp
  module Server
    module ConfigurationLoader
    	def self.server_config
    		name = config_file('jp-config')
        if name =~ /.ya?ml$/
          load_yaml_config_file(name)
        else
          load_ruby_config_file(name)
        end
    	end

    	private
      def self.load_yaml_config_file file
        config = YAML.load(File.read(file))
        symbolize_hash(config)
      end

      def self.symbolize_hash hash
        hash.dup.each do |k,v|
          if v.is_a? Hash
            symbolize_hash v
          end
          if k.is_a? String
            hash[k.to_sym] = v
          end
        end
        hash
      end

      def self.load_ruby_config_file file
        load file
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
  end
end
