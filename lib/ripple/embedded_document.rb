module Ripple
  module EmbeddedDocument
    extend ActiveSupport::Concern

    included do
      #extend ActiveModel::Naming
      extend Ripple::Properties
      include Ripple::AttributeMethods
      include Ripple::Callbacks

      include Ripple::Inspection
    end

    module ClassMethods
      def instantiate(attrs)
        self.allocate.tap do |object|
          object.instance_variable_set("@new", true)
          object.raw_attributes = attrs
        end
      end

      def embedded_in(parent)
        define_method(parent) { @_parent_document }
      end

      def associations
        @associations ||= {}
      end

      def embeddable?
        true
      end
    end

    attr_accessor :_parent_document

    def initialize(attrs = nil)
      @new = true
    end

    def new?
      @new || false
    end

  end
end