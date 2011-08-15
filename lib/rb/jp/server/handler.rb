require 'jp/thrift'
require 'jp/server/mongo_connection'
require 'jp/server/pools'

module Jp
  module Server
    # Implementation class.
    #
    # Does not include Thrift code, etc.
    class Handler
      include MongoConnection
      include Pools
      attr_reader :retry_attempts, :retry_delay
      def initialize options = {}
        # Option defaults
        defaults = {
          :mongo_retry_attempts => 10,
          :mongo_retry_delay    => 1,
        }
        options = defaults.merge(options)
        # Copy with/deal with options
        @retry_attempts = options[:mongo_retry_attempts]
        @retry_delay    = options[:mongo_retry_delay]

        load_pools(options)
        connect_to_mongo(options)
      end

      def add pool, message
        raise NoSuchPool.new unless pools.member? pool

        doc = {
          'message'     => message,
          'locked'       => false,
        }

        rescue_connection_failure do
          database[pool].insert doc
        end
      end

      def acquire pool
        raise NoSuchPool.new unless pools.member? pool
        now = Time.new.to_i
        doc = {}
        begin
          rescue_connection_failure do
            doc = database[pool].find_and_modify(
              query: {
                'locked' => false
              },
              update: {
                '$set' => {
                  'locked'       => now,
                  'locked_until' => now + pools[pool][:timeout],
                },
              }
            )
          end
        rescue Mongo::OperationFailure => e
          raise EmptyPool
        end
        job = Job.new
        job.message = doc['message']
        job.id = doc['_id'].to_s
        job
      end

      def purge pool, id
        raise NoSuchPool.new unless pools.member? pool
        rescue_connection_failure do
          database[pool].remove _id: BSON::ObjectId(id)
        end
      end

      # Ensure retry upon failure
      # Based on code from http://www.mongodb.org/display/DOCS/Replica+Pairs+in+Ruby
      def rescue_connection_failure
        success = false
        retries = 0
        while !success
          begin
            yield
            success = true
          rescue Mongo::ConnectionFailure => ex
            retries += 1
            raise if retries >= @retry_attempts
            sleep(@retry_delay)
          end
        end
      end
    end
  end
end
