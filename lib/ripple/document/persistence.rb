require 'active_support/concern'

module Ripple
  module Document
    module Persistence
      extend ActiveSupport::Concern

      module ClassMethods

        # Instantiates a new record, applies attributes from a block, and saves it
        def create(*args, &block)
          new(*args, &block).tap {|s| s.save }
        end

        # Destroys all records one at a time.
        # Place holder while :delete to bucket is being developed.
        def destroy_all
          list(&:destroy)
        end

        def options
          {:timeout => 5_000, :returnbody => false}
        end
      end

      # @private
      def initialize(attrs = nil)
        super
        @new = true
        @deleted = false
      end

      # Determines whether this document has been deleted or not.
      def deleted?
        @deleted
      end

      # Determines whether this is a new document.
      def new?
        @new || false
      end

      # Saves the document in Riak.
      # @return [true,false] whether the document succeeded in saving
      def save(*args)
        really_save(*args)
      end

      def really_save(*args)
        update_robject
        robject.store(self.class.options)
        self.key = robject.key

        @new     = false
        true
      end

      # Reloads the document from Riak
      # @return self
      def reload
        return self if new?
        @robject = @robject.reload(:force => true)
        reset_associations
        @changes = nil

        self.__send__(:raw_attributes=, @robject.data)
        self
      end

      # Deletes the document from Riak and freezes this instance
      def destroy!
        robject.delete(self.class.options) unless new?
        @deleted = true
      end

      def destroy
        destroy!
        true
      rescue Riak::FailedRequest
        false
      end

      attr_writer :robject

      def robject
        @robject ||= Riak::RObject.new(self.class.bucket, key).tap do |obj|
          obj.content_type = "application/json"
        end
      end

      def update_robject
        robject.key = key if robject.key != key
        robject.content_type = 'application/json'
        robject.data = attributes_for_persistence
      end

      private
      def attributes_for_persistence
        raw_attributes
      end
    end
  end
end
