require 'snappy'

module Ripple
  module SnappySerializer
    extend self

    def dump(obj)
      Snappy.deflate obj.to_json(Riak.json_options)
    end

    def load(binary)
      Riak::JSON.parse(Snappy.inflate binary)
    end
  end
end

Riak::Serializers['application/x-snappy'] = Ripple::SnappySerializer
