class JpConfig
	def pools
		{
			'test' => {
				:timeout => 500 # consumers must process entries within 5 minutes
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
