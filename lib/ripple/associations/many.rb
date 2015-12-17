module Ripple
  module Associations
    class Many < Proxy

      def <<(docs)
        load_target
        docs = Array.wrap(docs)
        assign_references(docs)
        @target += docs
        self
      end

      def replace(docs)
        reset

        @_length  = (docs || []).length unless @_docs
        @changed  = true if @_docs && docs != @_docs

        @_docs = (docs || []).map do |doc|
          doc.respond_to?(:attributes_for_persistence) ? doc.attributes_for_persistence : doc
        end

        assign_references(docs)
        @_docs
      end

      def reset
        super
        @_length = nil
      end

      def changed?
        super || @_length != (@target||@_docs).length
      end

      protected
      def find_target
        docs = (@_docs || []).map do |attrs|
          klass.instantiate(attrs).tap do |doc|
            doc.instance_variable_set(:@new, false)
          end if attrs
        end

        assign_references(docs)
        docs
      end

    end
  end
end