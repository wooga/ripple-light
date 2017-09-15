require 'active_support/concern'
require 'active_model/attribute_methods'

module Ripple
  module Properties
    extend ActiveSupport::Concern

    def inherited(subclass)
      super
      subclass.properties.merge!(properties)
    end

    def properties
      @properties ||= {}
    end

    def property(key, type, options={})
      prop = Property.new(key, type, options)
      properties[key.to_sym] = prop
    end
  end

  class Property
    def initialize(key, type, options={})
      @options  = options.to_options
      @key      = key.to_sym
      @type     = type
      @short    = (options.delete(:short) || key).to_sym
      @castable = type.respond_to?(:ripple_cast)


      @default            = options[:default]
      @default_duplicable = @default && @default.duplicable?
      @default_callable   = @default && @default.respond_to?(:call)
    end

    def options
      @options
    end

    def key
      @key
    end

    def type
      @type
    end

    def short
      @short
    end

    def default
      if @default
        default = @default_duplicable ? @default.dup : @default
        type_cast( @default_callable ? default.call : default)
      end
    end

    def type_cast(value)
      @castable ? @type.ripple_cast(value) : value
    end
  end
end
