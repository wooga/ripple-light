module PersistenceProxy
  class Bucket
    attr_reader :client, :name

    def initialize(client, name)
      @client = client
      @name = name
    end

    def get(key, options = {})
      client.get_object(self, key, options)
    end
  end
end
