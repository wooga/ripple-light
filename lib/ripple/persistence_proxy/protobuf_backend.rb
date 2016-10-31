require 'ripple/persistence_proxy/protobuf/protocol_pb'
require 'socket'
require 'em-synchrony'
require 'em-synchrony/tcpsocket'

module PersistenceProxy
  class ProtobufBackend
    PROTOBUF_HEADER_SIZE = 5

    attr_reader :host, :port, :evented

    def initialize(host, port, evented)
      @host = host
      @port = port
      @evented = evented
    end

    def teardown
      reset_socket
    end

    def fetch_object(bucket, key)
      message = GetRequest.new(bucket: bucket, key: key)

      write_protobuff(:GetRequest, message)
      decode_response
    end

    def store_object(bucket, key, content_type, content)
      message = SaveRequest.new(bucket: bucket, key: key, contentType: content_type, content: content)

      write_protobuff(:SaveRequest, message)
      decode_response
    end

    def delete_object(bucket, key)
      message = DeleteRequest.new(bucket: bucket, key: key)

      write_protobuff(:DeleteRequest, message)
      decode_response
    end

    private

    def write_protobuff(message_type, request)
      reset_socket if socket && socket.closed?

      encoded = request.to_proto
      header  = [encoded.size, id_for_message(message_type)].pack("NC")

      socket.write(header + encoded)
    end

    def decode_response
      response_header = socket.read(PROTOBUF_HEADER_SIZE)

      raise SocketError, "Unexpected EOF on PBC socket" \
        if response_header.nil? || response_header.size != PROTOBUF_HEADER_SIZE

      size, message_id = response_header.unpack("NC")

      response_content = socket.read(size)
      raise SocketError, "Unexpected EOF on PBC socket" \
        if response_content.nil? || response_content.size != size

      class_for_message_id(message_id.to_i).decode(response_content)
    end

    def socket
      @socket ||= build_socket
    end

    def build_socket
      new_socket = if evented
                     EM::Synchrony::TCPSocket.new(host, port)
                   else
                     TCPSocket.new(host, port)
                   end

      new_socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)
      new_socket
    end

    def reset_socket
      @socket.close if @socket && !@socket.closed?
      @socket = nil
    end

    def class_for_message_id(message_id)
      case message_id
      when 0
        SaveRequest
      when 1
        SaveResponse
      when 2
        GetResponse
      when 3
        GetResponse
      when 4
        DeleteRequest
      when 5
        DeleteResponse
      end
    end

    def id_for_message(message)
      case message
        when :SaveRequest
          0
        when :SaveResponse
          1
        when :GetRequest
          2
        when :GetResponse
          3
        when :DeleteRequest
          4
        when :DeleteResponse
          5
      end
    end
  end
end
