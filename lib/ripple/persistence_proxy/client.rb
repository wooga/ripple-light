require 'ripple/persistence_proxy/bucket'
require 'ripple/persistence_proxy/protobuf_backend'
require 'ripple/persistence_proxy/pool'

module PersistenceProxy

  class Client
    # todo move errors here once we remove riak
    NETWORK_ERRORS = Riak::Client::NETWORK_ERRORS

    VALID_OPTIONS = [:proxy_host, :proxy_port]
    attr_reader :host, :port, :max_retries, :evented, :pool

    def initialize(options = {})
      @host = options.fetch(:proxy_host)
      @port = options.fetch(:proxy_port)
      @max_retries = options[:max_retries] || 0
      @evented = options[:evented] || false

      @pool = PersistenceProxy::Pool.new(evented,
        method(:new_protobuf_backend),
        lambda { |b| b.teardown }
      )
    end

    # TODO: Error handling for failing reads
    def get_object(bucket, key, options = {})
      take_backend do |backend|
        response =  with_error_handling(backend.fetch_object(bucket.name, key))

        PersistenceProxy::Object.new(bucket, key).tap do |object|
          object.content_type = response.contentType
          object.raw_data = response.content
        end
      end
    end

    # TODO: Error handling for failing writes
    def store_object(object, options = {})
      take_backend do |backend|
        with_error_handling(
          backend.store_object(
            object.bucket.name,
            object.key,
            object.content_type,
            object.content.raw_data
          )
        )
      end
    end

    def reload_object(object, options = {})
      get_object(object.bucket, object.key, options)
    end

    # TODO: Error handling for failing deletes
    def delete_object(object, options = {})
      take_backend do |backend|
        with_error_handling(
          backend.delete_object(
            object.bucket.name,
            object.key
          )
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

    def with_error_handling(response)
      case response.status
      when :Ok
          response
      when :NotFound
         raise Riak::ProtobuffsFailedRequest.new(:not_found, 'not_found')
      when :Error
         raise SocketError, "Error response from PBC"
      end
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
          # FIXME: Should not manage SocketError at this level
        rescue *NETWORK_ERRORS => e
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
