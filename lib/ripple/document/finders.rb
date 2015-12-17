require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/hash/except'
require 'active_support/core_ext/hash/slice'


module Ripple
  module Document
    module Finders
      extend ActiveSupport::Concern

      module ClassMethods

        def find(key)
          return find_one(key)
        end

        # Find all documents in the Document's bucket and return them.
        # @overload list()
        #   Get all documents and return them in an array.
        #   @param [Hash] options options to be passed to the
        #     underlying {Bucket#keys} method.
        #   @return [Array<Document>] all found documents in the bucket
        # @overload list() {|doc| ... }
        #   Stream all documents in the bucket through the block.
        #   @yield [Document] doc a found document
        # @note This operation is incredibly expensive and should not
        #     be used in production applications.
        def list
          if block_given?
            bucket.keys(options) do |keys|
              keys.each do |key|
                obj = find_one(key)
                yield obj if obj
              end
            end
            []
          else
            bucket.keys(options).inject([]) do |acc, k|
              obj = find_one(k)
              obj ? acc << obj : acc
            end
          end
        end

        private
        def find_one(key)
          instantiate(bucket.get(key, options))
        rescue Riak::FailedRequest => fr
          raise fr unless fr.not_found?
        end

        def instantiate(robject)
          self.new.tap do |doc|
            doc.__send__(:raw_attributes=, robject.data) if robject.data
            doc.key = robject.key
            doc.instance_variable_set(:@new, false)
            doc.instance_variable_set(:@robject, robject)
          end
        end
      end
    end
  end
end
