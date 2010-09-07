#!/usr/bin/env ruby
# Compatibility for Ruby 1.9.0 (as shipped with Debian Lenny)
# This version doesn't have a system base64 library

module Base64
	def decode64 str
		str.unpack('m')[0]
	end
	def encode64 bin
		[bin].pack("m")	
	end
end
