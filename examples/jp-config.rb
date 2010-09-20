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
			'thrift' => {
				:timeout          => 60,
				:cleanup_interval => 1,
			},
		}
	end

	def skip_embedded_unlocker
		# Defaults to false; if set to true, pool items won't be unlocked by the main jp daemon.
		# You might want to run a separate jp-unlocker process (just one) if you're running multiple
		# instances of the jp daemon against the same mongodb cluster.
		false
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
