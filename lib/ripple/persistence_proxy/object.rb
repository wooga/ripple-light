require 'ripple/persistence_proxy/content'
require 'forwardable'

module PersistenceProxy
  class Object
    extend Forwardable

    attr_accessor :key
    attr_reader :content, :bucket

    def_delegators :content,
      :content_type, :content_type=,
      :data, :data=,
      :raw_data, :raw_data=

    def initialize(bucket, key)
      @content = PersistenceProxy::Content.new
      @bucket = bucket
      @key = key

      yield self if block_given?
    end

    def store(options = {})
      @bucket.client.store_object(self, options)
      self
    end

    def reload(options = {})
      @bucket.client.reload_object(self, options)
    end

    def delete(options = {})
      @bucket.client.delete_object(self, options)
    end
  end
end
