require 'spec_helper'

describe Ripple::Callbacks do
  let(:doc) do
    _e = embedded

    Class.new do
      include Ripple::Document
      self.bucket_name = "docs"
      many :embeddeds, :class => _e

      property :save_callbacks_called, Array, default: []
      property :save_callbacks_order, Array, default: []

      before_save :before_save
      after_save :after_save
      around_save :around_save

      def before_save
        self.save_callbacks_called << :before
        self.save_callbacks_order << :before
      end

      def after_save
        self.save_callbacks_called << :after
        self.save_callbacks_order << :after
      end

      def around_save
        yield
        self.save_callbacks_called << :around
      end

      property :create_callbacks_called, Array, default: []

      before_create :before_create
      after_create :after_create
      around_create :around_create

      def before_create
        self.create_callbacks_called << :before
      end

      def after_create
        self.create_callbacks_called << :after
      end

      def around_create
        yield
        self.create_callbacks_called << :around
      end

      property :update_callbacks_called, Array, default: []

      before_update :before_update
      after_update :after_update
      around_update :around_update

      def before_update
        self.update_callbacks_called << :before
      end

      def after_update
        self.update_callbacks_called << :after
      end

      def around_update
        yield
        self.update_callbacks_called << :around
      end

      property :destroy_callbacks_called, Array, default: []

      before_destroy :before_destroy
      after_destroy :after_destroy
      around_destroy :around_destroy

      def before_destroy
        self.destroy_callbacks_called << :before
      end

      def after_destroy
        self.destroy_callbacks_called << :after
      end

      def around_destroy
        yield
        self.destroy_callbacks_called << :around
      end
    end
  end

  let(:embedded) do
    Class.new do
      include Ripple::EmbeddedDocument

      property :save_callbacks_called, Array, default: []

      before_save :before_save
      after_save :after_save

      def before_save
        self.save_callbacks_called << :before
      end

      def after_save
        self.save_callbacks_called << :after
      end

      property :create_callbacks_called, Array, default: []

      before_create :before_create
      after_create :after_create

      def before_create
        self.create_callbacks_called << :before
      end

      def after_create
        self.create_callbacks_called << :after
      end
    end
  end

  subject { doc.new }

  it "should add create, update, save, and destroy callback declarations" do
    [:save, :create, :update, :destroy].each do |event|
      expect(doc.instance_methods.map(&:to_s)).to include("_run_#{event}_callbacks")
      [:before, :after, :around].each do |time|
        expect(doc).to respond_to("#{time}_#{event}")
      end
    end
  end

  describe "invoking callbacks" do
    before :each do
      @client = Ripple.client
      allow(@client).to receive(:store_object) { true }
    end

    it "should call save callbacks on save" do
      expect(subject.save_callbacks_called).to eq([])
      subject.save
      expect(subject.save_callbacks_called).to eq([:before, :around, :after])
    end

    it "propagates callbacks to embedded associated documents" do
      child = embedded.new
      subject.embeddeds << child

      expect(child.save_callbacks_called).to eq([])
      subject.save
      expect(child.save_callbacks_called).to eq([:before, :after])
    end

    it 'does not persist the object to riak multiple times when propagating callbacks' do
      subject.embeddeds << embedded.new << embedded.new

      expect(subject.robject).to receive(:store).once
      subject.save
    end

    it 'invokes the before/after callbacks in the correct order on embedded associated documents' do
      subject.embeddeds << embedded.new
      allow(subject.robject).to receive(:store) do
        subject.save_callbacks_order << :save
      end
      subject.save

      expect(subject.save_callbacks_order).to eq([:before, :save, :after])
    end

    it "should call create callbacks on save when the document is new" do
      expect(subject.create_callbacks_called).to eq([])
      subject.save
      expect(subject.create_callbacks_called).to eq([:before, :around, :after])
    end

    it "should call update callbacks on save when the document is not new" do
      expect(subject.update_callbacks_called).to eq([])

      allow(subject).to receive(:new?) { false }
      subject.save
      expect(subject.update_callbacks_called).to eq([:before, :around, :after])
    end

    describe "destroy callbacks" do
      it "invokes them when #destroy is called" do
        expect(subject.destroy_callbacks_called).to eq([])
        subject.destroy
        expect(subject.destroy_callbacks_called).to eq([:before, :around, :after])
      end

      it "invokes them when #destroy! is called" do
        expect(subject.destroy_callbacks_called).to eq([])
        subject.destroy!
        expect(subject.destroy_callbacks_called).to eq([:before, :around, :after])
      end
    end
  end
end
