#!/usr/bin/env ruby
# Tricks needed for compatibility with Ruby 1.9.0 as shipped on Debian Lenny
unless Encoding.respond_to? :default_internal
	def Encoding.default_internal
		nil
	end
end
