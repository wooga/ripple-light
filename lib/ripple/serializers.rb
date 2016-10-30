require 'riak'
require 'snappy'

Riak.json_options.merge!(symbolize_keys: true)

module Ripple
  module SnappySerializer
    extend self

    def dump(obj)
      Snappy.deflate Riak::JSON.encode(obj)
    end

    def load(binary)
      Riak::JSON.parse(Snappy.inflate binary)
    end
  end
end

Riak::Serializers['application/x-snappy'] = Ripple::SnappySerializer
