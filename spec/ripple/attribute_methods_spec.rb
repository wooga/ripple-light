require 'spec_helper'

describe Ripple::AttributeMethods do
  before do
    @bar = Bar.new
  end

  describe "#attribute" do
    it "should return the default value" do
      expect(@bar.default).to eq('bar')
    end

    it "return nil if not set" do
      expect(@bar.foo).to eq(nil)
    end

    it "return the value set before" do
      @bar.attributes[:foo] = "12"
      expect(@bar.foo).to eq("12")
    end
  end

  describe "#changed?" do
    it "return false if nothing has changed" do
      expect(@bar.changed?).to be(false)
    end

    it "return true if changed" do
      @bar.foo = "12"
      expect(@bar.changed?).to be(true)
    end
  end

  describe "changes" do
    it "return a empty hash if nothing has changed" do
      expect(@bar.changes).to eq({})
    end

    it "return a hash with changes" do
      @bar.foo = "12"
      expect(@bar.changes).to eq({:foo => nil})
    end
  end

  describe "#attribute=" do
    it "set the value" do
      @bar.foo = "12"
      expect(@bar.attributes).to eq({:foo => "12"})
    end
  end

  describe "#raw_attributes=" do
    it "should set the attributes" do
      @bar.raw_attributes = {:f => "12"}
      expect(@bar.attributes).to eq({:foo => "12"})
    end

    it "should cast the values" do
      @bar.raw_attributes = {:f => 1}
      expect(@bar.attributes).to eq({:foo => "1"})
    end

    describe "with associations" do
      before do
        @customer = Customer.new
      end

      it "should set raw attributes on the associations" do
        allow_message_expectations_on_nil
        expect(@customer.email).to receive(:replace).with(:a => 'foo')
        @customer.raw_attributes = {:e => {:a => 'foo'}, :n => 'bar'}
      end
    end
  end

  describe "#raw_attributes" do
    it "should not return nil values" do
      @bar.foo = nil
      expect(@bar.raw_attributes).to eq({})
    end

    it "should not return blank values" do
      @bar.foo = " "
      expect(@bar.raw_attributes).to eq({})
    end

    it "should not return default values" do
      @bar.default = "bar"
      expect(@bar.raw_attributes).to eq({})
    end

    it "should return a hash with short names" do
      @bar.foo      = "12"
      @bar.default  = "45"
      expect(@bar.raw_attributes).to eq({:f => "12", :d => "45"})
    end
  end
end
