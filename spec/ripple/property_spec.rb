require 'spec_helper'

describe Ripple::Property do
  it "should make the model class have a property definition method" do
    Bar.should respond_to(:property)
  end

  it "should add properties to the class via the property method" do
    Bar.property :foo, String
    Bar.properties.should include(:foo)
  end

  it "should make the model class have a collection of properties" do
    Bar.should respond_to(:properties)
    Bar.properties.should be_kind_of(Hash)
  end

  it "should make subclasses inherit properties from the parent class" do
    Bar.properties[:foo] = "bar"
    class Forward < Bar; end
    Bar.properties[:foo].should == "bar"
  end

  describe Ripple::Property do
    it "should have a key symbol" do
      prop = Ripple::Property.new('foo', String)
      prop.should respond_to(:key)
      prop.key.should == :foo
    end

    it "should have a type" do
      prop = Ripple::Property.new('foo', String)
      prop.should respond_to(:type)
      prop.type.should == String
    end

    it "should have a short key" do
      prop = Ripple::Property.new('foo', String, :short => :bar)
      prop.should respond_to(:short)
      prop.short.should == :bar
    end

    it "should use the key as fallback when no short key is defined" do
      prop = Ripple::Property.new('foo', String)
      prop.should respond_to(:short)
      prop.short.should == :foo
    end

    describe "default value" do
      it "should be nil when not specified" do
        prop = Ripple::Property.new('foo', String)
        prop.default.should be_nil
      end

      it "should allow literal values" do
        prop = Ripple::Property.new('foo', String, :default => "bar")
        prop.default.should == "bar"
      end

      it "should cast to the proper type" do
        prop = Ripple::Property.new('foo', String, :default => :bar)
        prop.default.should == "bar"
      end

      it "should return default value when defined" do
        prop = Ripple::Property.new('foo', String, :default => 'bar')
        prop.should respond_to(:default)
        prop.default.should == 'bar'
      end

      it "should duplicate default value" do
        prop = Ripple::Property.new('foo', String, :default => 'bar')
        prop.should respond_to(:default)
        prop.default.should == 'bar'
      end

      it "should allow lambdas for deferred evaluation" do
        prop = Ripple::Property.new('foo', String, :default => lambda { "bar" })
        prop.default.should == "bar"
      end
    end


  end
end