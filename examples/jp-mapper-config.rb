class JpMapperConfig
	def host_for_pool pool
		case pool
			when 'foo'
				{host: 'localhost', port: 9090}
			when /^foo/
				{host: 'localhost', port: 9091}
			when 'bar'
				{host: 'localhost', port: 9092}
			else
				{host: 'localhost', port: 9093}
				# Alternatively:
				# raise Jp::NoSuchPool.new
		end
	end
end
