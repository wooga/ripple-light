require 'active_support/concern'
require 'active_model/callbacks'

module Ripple
  module Callbacks
    extend ActiveSupport::Concern

    CALLBACK_TYPES = [:create, :update, :save, :destroy]

    included do
      extend ActiveModel::Callbacks
      define_model_callbacks *CALLBACK_TYPES
    end

    def really_save(*args, &block)
      run_save_callbacks do
        super
      end
    end

    def run_save_callbacks
      state = new? ? :create : :update
      run_callbacks(:save) do
        run_callbacks(state) do
          yield
        end
      end
    end

    def destroy!(*args, &block)
      run_callbacks(:destroy) do
        super
      end
    end
  end
end
