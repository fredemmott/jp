module Jp
  module Server
    module Pools
      attr_reader :pools
      protected
      def load_pools options
        defaults = {
          :default_timeout => 3600, # 1 hour
        }
        options = defaults.merge(options)

        unless options[:pools]
          raise ArgumentError.new "pools option must be specified"
        end
        if options[:pools].empty?
          raise ArgumentError.new "pools option must not be empty"
        end

        @pools = Hash.new
        options[:pools].each do |name, data|
          data[:timeout]          ||= options[:default_timeout]
          data[:cleanup_interval] ||= data[:timeout]
          @pools[name] = data
        end
      end
    end
  end
end
