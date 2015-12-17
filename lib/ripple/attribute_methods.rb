require 'active_support/concern'
require 'active_support/core_ext/object/blank'

require 'active_model/attribute_methods'


module Ripple
  module AttributeMethods
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    included do
      attribute_method_suffix "="
    end

    module ClassMethods
      # @private
      def property(key, type, options={})
        super.tap do
          define_attribute_method(key.to_sym)
        end
      end

      def define_method_attribute=(attr_name)
        attr_name = attr_name.to_sym
        self.class_eval <<-RUBY
          def #{attr_name}
            attribute(:#{attr_name}, #{properties[attr_name].default != nil})
          end

          def #{attr_name}=(value)
            set_attribute(:#{attr_name}, value)
          end
        RUBY
      end
    end

    def initialize(attrs = nil)
      @attributes = attrs
      super
    end

    def raw_attributes=(attrs)
      attrs = {} if attrs.nil?
      @attributes = self.class.properties.inject(Hash.new) do |result, (key, prop)|
        value = attrs[prop.short]

        result[key] = prop.type_cast(value) if value
        result
      end

      self.class.associations.each do |k,assoc|
        value = attrs[assoc.short_name]
        __send__("#{k}=",value)
      end
    end

    def raw_attributes
      self.class.properties.inject(Hash.new) do |result, (key, prop)|
        value              = attribute(key)
        result[prop.short] = value unless \
          value.blank? || value == prop.default

        result
      end
    end

    def attributes_for_persistence
      raw_attributes
    end

    def attributes
      @attributes ||= {}
    end

    def changes
      @changes ||= {}
    end

    def changed?
      !!(@changes && @changes.any?)
    end

protected

    def set_attribute(attr_name, value)
      if attributes[attr_name] != value
        changes[attr_name] = attributes[attr_name] unless changes[attr_name]
      end
      attributes[attr_name] = value
    end

    def attribute(attr_name, default = false)
      if default
        attributes[attr_name] ||= self.class.properties[attr_name].default
      else
        attributes[attr_name]
      end
    end
  end
end
