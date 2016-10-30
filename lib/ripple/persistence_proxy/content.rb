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
      if content_type == "application/x-snappy"
        Snappy.deflate JSON.generate(payload)
      elsif content_type == "application/json"
        payload.to_json
      end
    end

    def deserialize(payload)
      if content_type == "application/x-snappy"
        JSON.parse(Snappy.inflate(payload), symbolize_names: true)
      elsif content_type == "application/json"
        JSON.parse(payload, symbolize_names: true)
      end
    end
  end
end
