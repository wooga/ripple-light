require 'snappy'

module Ripple
  module ZipSerializer
    extend self

    def dump(obj)
      Snappy.deflate obj.to_json
    end

    def load(binary)
      JSON.parse(Snappy.inflate binary)
    end
  end
end

Riak::Serializers['application/zip'] = Ripple::ZipSerializer
