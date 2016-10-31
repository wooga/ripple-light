require 'riak'
require 'ripple/document'
require 'ripple/embedded_document'
require 'ripple/core_ext'
require 'ripple/serializers'
require 'ripple/persistence_proxy'
require 'active_support/core_ext'

Riak::Client::VALID_OPTIONS += PersistenceProxy::Client::VALID_OPTIONS

module Ripple
  class << self

    def client
      Thread.current[:ripple_client] ||= client_class.new(client_config)
    end

    def client_class
      if Thread.current[:persistence_proxy]
        PersistenceProxy::Client
      else
        Riak::Client
      end
    end

    def robject_class
      if Thread.current[:persistence_proxy]
        PersistenceProxy::Object
      else
        Riak::RObject
      end
    end

    def client=(value)
      Thread.current[:ripple_client] = value
    end

    def config=(hash)
      self.client = nil
      @config = hash.symbolize_keys
    end

    def config
      @config ||= {}
    end

    def date_format
      (config[:date_format] ||= :iso8601).to_sym
    end

    def date_format=(format)
      config[:date_format] = format.to_sym
    end

    def load_configuration(config_file, config_keys = [:ripple])
      config_file = File.expand_path(config_file)
      config_hash = YAML.load(ERB.new(File.read(config_file)).result).with_indifferent_access
      config_keys.each {|k| config_hash = config_hash[k]}
      configure_ports(config_hash)
      self.config = config_hash || {}
    rescue Errno::ENOENT
      raise Ripple::MissingConfiguration.new(config_file)
    end
    alias_method :load_config, :load_configuration

    private
    def configure_ports(config)
      return unless config && config[:min_port]
      config[:http_port] ||= (config[:min_port].to_i)
      config[:pb_port] ||= (config[:min_port].to_i + 1)
    end

    def client_config
      config.slice(*valid_options)
    end

    def valid_options
      Riak::Client::VALID_OPTIONS
    end
  end
end

require 'ripple/railtie' if defined? Rails::Railtie
