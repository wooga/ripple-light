require 'ripple/persistence_proxy/bucket'
require 'ripple/persistence_proxy/protobuf_backend'
require 'ripple/persistence_proxy/pool'

module PersistenceProxy
  class Client
    attr_reader :host, :port, :max_retries, :evented, :pool

    def initialize(options = {})
      @host = options.fetch(:host)
      @port = options.fetch(:pb_port)
      @max_retries = options[:max_retries] || 0
      @evented = options[:evented] || false

      @pool = PersistenceProxy::Pool.new(evented,
        method(:new_protobuf_backend),
        lambda { |b| b.teardown }
      )
    end

    def store_object(object, options = {})
      take_backend do |backend|
        backend.store_object(
          object.bucket.name, 
          object.key, 
          object.content_type, 
          object.content.raw_data
        )
      end
    end

    def bucket(name)
      @bucket_cache ||= {}
      @bucket_cache[name] ||= PersistenceProxy::Bucket.new(self, name)
    end

    private

    def new_protobuf_backend
      PersistenceProxy::ProtobufBackend.new(host, port, evented)
    end

    def take_backend(&block)
      skip_backend = []
      take_options = {}

      tries = 1 + max_retries

      begin
        # Only take sockets which haven't been used before
        unless skip_backend.empty?
          take_options[:filter] = lamba do |backend|
            not skip_backend.include? backend
          end
        end

        pool.take(take_options) do |backend|
          begin 
            yield backend
          rescue => e
            # Log error
            puts "Protobuf error: #{e.inspect} for #{backend.inspect}"

            tries -= 1

            skip_backend << backend

            raise PersistenceProxy::Pool::BadResource, e
          end
        end
      rescue PersistenceProxy::Pool::BadResource => e
        retry if tries > 0
        raise e.message
      end
    end
  end
end
