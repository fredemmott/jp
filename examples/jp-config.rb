class JpConfig
	def pools
		{
			'text' => {
				:timeout          => 60,
				:cleanup_interval => 1,
			},
			'json' => {
				:timeout          => 60,
				:cleanup_interval => 1,
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
		'jp_examples'
	end
end
