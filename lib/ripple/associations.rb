require 'active_support/concern'
require 'active_support/dependencies'

require 'ripple/associations/proxy'
require 'ripple/associations/many'
require 'ripple/associations/one'

module Ripple

  module Associations
    extend ActiveSupport::Concern

    module ClassMethods
      def inherited(subclass)
        super
        subclass.associations.merge!(associations)
      end

      # Associations defined on the document
      def associations
        @associations ||= {}
      end

      def one(name, options={})
        create_association(:one, name, options)
      end

      def many(name, options={})
        create_association(:many, name, options)
      end

    private

      def create_association(type, name, options={})
        association = associations[name] = Association.new(type, name, options)

        define_method(name) do
          get_proxy(association)
        end

        define_method("#{name}=") do |value|
          get_proxy(association).replace(value)
          value
        end

        unless association.many?
          define_method("#{name}?") do
            get_proxy(association).present?
          end
        end
      end
    end

    def get_proxy(association)
      unless proxy = instance_variable_get(association.ivar)
        proxy = association.proxy_class.new(self, association)
        instance_variable_set(association.ivar, proxy)
      end
      proxy
    end

    def attributes_for_persistence
      self.class.associations.inject(super) do |result, (_, assoc)|
        documents = instance_variable_get(assoc.ivar)

        if documents && (!documents.loaded? || !documents.changed?)
          value = documents.instance_variable_get(assoc.many? ? :@_docs : :@_doc)
        elsif !documents.nil?
          value = assoc.many? ? documents.map(&:attributes_for_persistence) : documents.attributes_for_persistence
        end

        result[assoc.short_name] = value \
          unless value.blank?
        result
      end
    end

    def changed?
      changed = super
      changed || self.class.associations.each do |_, assoc|
        documents = instance_variable_get(assoc.ivar)
        break if documents && changed = documents.changed?
      end

      changed || false
    end

    def reset_associations
      self.class.associations.each do |name, _|
        send(name).reset
      end
    end

    def propagate_callbacks_to_embedded_associations(name, kind)
      self.class.associations.each do |_, assoc|
        documents = instance_variable_get(assoc.ivar)

        next unless documents
        next if !documents.loaded? || !documents.changed? || documents.nil?

        callback = "_#{name}_callbacks"
        Array.wrap(documents.target).each do |doc|
          doc.send(callback).each do |callback|
            next unless callback.kind == kind
            doc.send(callback.filter)
          end if doc && (doc.changed? || doc.new?)
        end
      end
    end

    included do
      def run_callbacks(name, *args, &block)
        propagate_callbacks_to_embedded_associations(name, :before)
        return_value = super
        propagate_callbacks_to_embedded_associations(name, :after)
        return_value
      end
    end

  end

  class Association
    attr_reader :type, :name, :options

    # association options :using, :class_name, :class, :extend,
    # options that may be added :validate

    def initialize(type, name, options={})
      @type, @name, @options = type, name, options.to_options
      @short_name = (@options.delete(:short) || name).to_sym
    end

    def short_name
      @short_name
    end

    def klass
      @klass ||= options[:class_name].constantize
    end

    # @return [true,false] Is the cardinality of the association > 1
    def many?
      @type == :many
    end

    # @return [true,false] Is the cardinality of the association == 1
    def one?
      @type == :one
    end

    # @return [String] the instance variable in the owner where the association will be stored
    def ivar
      @ivar ||= "@_#{name}"
    end

    # @return [Class] the association proxy class
    def proxy_class
      @proxy_class ||= proxy_class_name.constantize
    end

    # @return [String] the class name of the association proxy
    def proxy_class_name
      @proxy_class_name ||= "Ripple::Associations::#{(many? ? 'Many' : 'One')}"
    end
  end
end
