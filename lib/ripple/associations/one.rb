require 'ripple/associations/proxy'

module Ripple
  module Associations
    class One < Proxy

      def replace(doc)
        assign_references(doc)
        if doc.is_a?(klass)
          @_doc   = doc.attributes_for_persistence
          @target = doc
          loaded
        else
          reset
          @changed = true if @_doc && doc != @_doc
          @_doc    = doc
        end
        @_doc
      end

      protected
      def find_target
        klass.instantiate(@_doc).tap do |doc|
          assign_references(doc)
          doc.instance_variable_set(:@new, false)
        end if @_doc
      end
    end
  end
end
