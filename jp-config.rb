class JpConfig
	def pools
		{
			'test' => {
				:timeout          => 300, # consumers must process entries within 5 minutes
				:cleanup_interval => 60,  # look for timed-out entries every minute
			},
		}
	end

	def port_number
		9090
	end

	def mongo_uri
		'mongodb://localhost'
	end

	def mongo_db
		'jb_test'
	end
end
