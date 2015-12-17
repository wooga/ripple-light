require 'spec_helper'

describe Ripple::AttributeMethods do
  before do
    @bar = Bar.new
  end

  describe "#attribute" do
    it "should return the default value" do
      @bar.default.should == 'bar'
    end

    it "return nil if not set" do
      @bar.foo.should == nil
    end

    it "return the value set before" do
      @bar.attributes[:foo] = "12"
      @bar.foo.should == "12"
    end
  end

  describe "#changed?" do
    it "return false if nothing has changed" do
      @bar.changed?.should == false
    end

    it "return true if changed" do
      @bar.foo = "12"
      @bar.changed?.should == true
    end
  end

  describe "changes" do
    it "return a empty hash if nothing has changed" do
      @bar.changes.should == {}
    end

    it "return a hash with changes" do
      @bar.foo = "12"
      @bar.changes.should == {:foo => nil}
    end
  end

  describe "#attribute=" do
    it "set the value" do
      @bar.foo = "12"
      @bar.attributes.should == {:foo => "12"}
    end
  end


  describe "#raw_attributes=" do
    it "should set the attributes" do
      @bar.raw_attributes = {:f => "12"}
      @bar.attributes.should == {:foo => "12"}
    end

    it "should cast the values" do
      @bar.raw_attributes = {:f => 1}
      @bar.attributes.should == {:foo => "1"}
    end

    describe "with associations" do
      before do
        @customer = Customer.new
      end

      it "should set raw attributes on the associations" do
        allow_message_expectations_on_nil
        @customer.email.should_receive(:replace).with(:a => 'foo')
        @customer.raw_attributes = {:e => {:a => 'foo'}, :n => 'bar'}
      end
    end
  end

  describe "#raw_attributes" do
    it "should not return nil values" do
      @bar.foo = nil
      @bar.raw_attributes.should == {}
    end

    it "should not return blank values" do
      @bar.foo = " "
      @bar.raw_attributes.should == {}
    end

    it "should not return default values" do
      @bar.default = "bar"
      @bar.raw_attributes.should == {}
    end

    it "should return a hash with short names" do
      @bar.foo      = "12"
      @bar.default  = "45"
      @bar.raw_attributes.should == {:f => "12", :d => "45"}
    end
  end
end