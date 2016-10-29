require 'ripple/persistence_proxy/content'
require 'forwardable'

module PersistenceProxy
  class Object
    extend Forwardable

    attr_accessor :key
    attr_reader :content, :bucket

    def_delegators :content,
      :content_type, :content_type=,
      :data, :data=

    def initialize(bucket, key)
      @content = PersistenceProxy::Content.new
      @bucket = bucket

      yield self if block_given?
    end

    def store(options = {})
      @bucket.client.store_object(self, options)
      self
    end
  end
end
