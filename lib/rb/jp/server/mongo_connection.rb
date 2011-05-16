module Jp
  module Server
    module MongoConnection
      attr_reader :database
      def connect_to_mongo options
        defaults = {
          :mongo_uri            => 'mongodb://localhost',
          :mongo_pool_size      => 10,
          :mongo_pool_timeout   => 60,
        }
        options = defaults.merge(options)
        # Connect to mongodb
        if options.member? :injected_mongo_database then
          @database = options[:injected_mongo_database]
        else
          connection = Mongo::Connection.from_uri(
            options[:mongo_uri],
            :pool_size => options[:mongo_pool_size],
            :timeout   => options[:mongo_pool_timeout],
          )
          @database = connection.db(options[:mongo_db])
        end
      end
    end
  end
end
