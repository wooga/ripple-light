#require 'active_support/core_ext/module/delegation'
require 'ripple/associations'

module Ripple
  module Associations
    class Proxy
      instance_methods.each do |m|
        undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id|^instance_variable_get$)/
      end

      attr_reader :owner, :reflection, :target

      def initialize(owner, reflection)
        @owner, @reflection = owner, reflection
        reset
      end

      def assign_references(docs)
        Array.wrap(docs).each do |doc|
          next unless doc.respond_to?(:_parent_document=)
          doc._parent_document = owner
        end
      end

      def instantiate_target(*args)
        doc = super
        assign_references(doc)
        doc
      end

      def inspect
        load_target
        target.inspect
      end

      def loaded?
        @loaded
      end

      def loaded
        @loaded = true
      end

      def nil?
        load_target
        target.nil?
      end

      def blank?
        load_target
        target.blank?
      end

      def present?
        load_target
        target.present?
      end

      def reload
        reset
        load_target
        self unless target.nil?
      end

      def reset
        @loaded  = false
        @target  = nil
        @changed = nil
      end

      def ===(other)
        load_target
        other === target
      end

      def inspect
        load_target
        target.inspect
      end

      def as_json
        load_target
        target.as_json
      end

      def changed?
        changed = @changed
        changed || Array.wrap(@target).each do |doc|
          break if changed = doc.changed?||doc.new?
        end if loaded?

        changed
      end

      protected
      def method_missing(method, *args, &block)
        load_target

        if block_given?
          target.send(method, *args)  { |*block_args| block.call(*block_args) }
        else
          target.send(method, *args)
        end
      end

      def load_target
        @target = find_target unless loaded?
        loaded
        @target
      end

      def klass
        @reflection.klass
      end

      def find_target
        raise NotImplementedError
      end
    end
  end
end