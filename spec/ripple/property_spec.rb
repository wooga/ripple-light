require 'spec_helper'

describe Ripple::Property do
  it "should make the model class have a property definition method" do
    expect(Bar).to respond_to(:property)
  end

  it "should add properties to the class via the property method" do
    Bar.property :foo, String
    expect(Bar.properties).to include(:foo)
  end

  it "should make the model class have a collection of properties" do
    expect(Bar).to respond_to(:properties)
    expect(Bar.properties).to be_kind_of(Hash)
  end

  it "should make subclasses inherit properties from the parent class" do
    Bar.properties[:foo] = "bar"
    class Forward < Bar; end
    expect(Bar.properties[:foo]).to eq("bar")
  end

  describe Ripple::Property do
    it "should have a key symbol" do
      prop = Ripple::Property.new('foo', String)
      expect(prop).to respond_to(:key)
      expect(prop.key).to eq(:foo)
    end

    it "should have a type" do
      prop = Ripple::Property.new('foo', String)
      expect(prop).to respond_to(:type)
      expect(prop.type).to eq(String)
    end

    it "should have a short key" do
      prop = Ripple::Property.new('foo', String, :short => :bar)
      expect(prop).to respond_to(:short)
      expect(prop.short).to eq(:bar)
    end

    it "should use the key as fallback when no short key is defined" do
      prop = Ripple::Property.new('foo', String)
      expect(prop).to respond_to(:short)
      expect(prop.short).to eq(:foo)
    end

    describe "default value" do
      it "should be nil when not specified" do
        prop = Ripple::Property.new('foo', String)
        expect(prop.default).to be_nil
      end

      it "should allow literal values" do
        prop = Ripple::Property.new('foo', String, :default => "bar")
        expect(prop.default).to eq("bar")
      end

      it "should cast to the proper type" do
        prop = Ripple::Property.new('foo', String, :default => :bar)
        expect(prop.default).to eq("bar")
      end

      it "should return default value when defined" do
        prop = Ripple::Property.new('foo', String, :default => 'bar')
        expect(prop).to respond_to(:default)
        expect(prop.default).to eq('bar')
      end

      it "should duplicate default value" do
        prop = Ripple::Property.new('foo', String, :default => 'bar')
        expect(prop).to respond_to(:default)
        expect(prop.default).to eq('bar')
      end

      it "should allow lambdas for deferred evaluation" do
        prop = Ripple::Property.new('foo', String, :default => lambda { "bar" })
        expect(prop.default).to eq("bar")
      end
    end
  end
end
