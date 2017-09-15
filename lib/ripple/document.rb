require 'active_support/concern'
require 'active_support/callbacks'

require 'ripple/core_ext'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/object/duplicable'
require 'active_support/core_ext/hash/keys'

require 'ripple/properties'
require 'ripple/attribute_methods'
require 'ripple/associations'
require 'ripple/callbacks'
require 'ripple/inspection'

require 'ripple/document/bucket_access'
require 'ripple/document/key'
require 'ripple/document/persistence'
require 'ripple/document/finders'


module Ripple
  module Document
    extend ActiveSupport::Concern

    included do
      extend BucketAccess
      include Ripple::Document::Key
      include Ripple::Document::Persistence
      extend Ripple::Properties
      include Ripple::Document::Finders

      include Ripple::AttributeMethods
      include Ripple::Associations
      include Ripple::Callbacks

      include Ripple::Inspection
    end

    module ClassMethods
      def embeddable?
        false
      end
    end

    def initialize(attrs = nil)

    end
  end
end
