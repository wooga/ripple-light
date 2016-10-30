require 'riak/serializers'

module PersistenceProxy
  class Content
    attr_accessor :content_type

    def data=(new_data)
      @raw_data = nil
      @data = new_data
    end

    def data
      if @raw_data && !@data
        @data = deserialize(@raw_data)
        @raw_data = nil
      end
      @data
    end

    def raw_data=(new_raw_data)
      @data = nil
      @raw_data = new_raw_data
    end

    def raw_data
      if @data && !@raw_data
        @raw_data = serialize(@data)
        @data = nil
      end
      @raw_data
    end

    def serialize(payload)
      Riak::Serializers.serialize(content_type, payload)
    end

    def deserialize(body)
      Riak::Serializers.deserialize(content_type, body)
    end
  end
end
