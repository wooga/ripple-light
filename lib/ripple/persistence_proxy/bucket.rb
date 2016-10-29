module PersistenceProxy
  class Bucket
    attr_reader :client, :name

    def initialize(client, name)
      @client = client
      @name = name
    end
  end
end
