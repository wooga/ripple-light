require 'spec_helper'

describe Ripple::Associations do

  it "should provide access to the associations hash" do
    Customer.should respond_to(:associations)
    Customer.associations.should be_kind_of(Hash)
  end

  describe "when adding a :many association" do
    it "should add accessor and mutator methods" do
      Customer.many :foos, :class_name => 'Email'
      Customer.instance_methods.map(&:to_sym).should include(:foos)
      Customer.instance_methods.map(&:to_sym).should include(:foos=)
    end
  end

  describe "when adding a :one association" do
    it "should add accessor, mutator, and query methods" do
      Customer.one :foo, :class_name => 'Email'
      Customer.instance_methods.map(&:to_sym).should include(:foo)
      Customer.instance_methods.map(&:to_sym).should include(:foo=)
      Customer.instance_methods.map(&:to_sym).should include(:foo?)
    end
  end

  describe "changed?" do
    describe "many" do
      before do
        @car = Car.new.tap do |e|
          e.raw_attributes = {:t => [{:a => 0}, {:a => 1}], :n => 'bar'}
        end
      end

      it "should return false if the asscociation has not been loaded" do
        @car.should_not be_changed
      end

      it "should return false if the asscociation has been loaded but not modified" do
        @car.tire.first.foo.should == 0
        @car.should_not be_changed
      end

      it "should return true if the asscociation has been loaded and is modified" do
        @car.tire.first.foo = 2
        @car.should be_changed
      end

      it "should return true if the asscociation has been added" do
        @car.tire << Tire.new(:foo => 2)
        @car.should be_changed
      end

      it "should not evaluate associations when the base class has been changed" do
        Tire.any_instance.should_receive(:changed?).never
        @car.name = 'bar 2'
        @car.should be_changed
      end

      it "should return true if a element has been deleted" do
        @car.tire.reject!{|f| f.foo == 1}
        @car.should be_changed
        @car.tire.length.should == 1
      end
    end

    describe "one" do
      before do
        @customer = Customer.new.tap do |e|
          e.raw_attributes = {:e => {:a => 'foo'}, :n => 'bar'}
        end
      end

      it "should return false if the asscociation has not been loaded" do
        @customer.should_not be_changed
      end

      it "should return false if the asscociation has been loaded but not modified" do
        @customer.email.address.should == 'foo'
        @customer.should_not be_changed
      end

      it "should return true if the asscociation has been loaded and is modified" do
        @customer.email.address = 'new foo'
        @customer.should be_changed
      end

      it "should return true if the asscociation has been replaced" do
        @customer.email = Email.new
        @customer.should be_changed
      end

      it "should not evaluate associations when the base class has been changed" do
        Email.any_instance.should_receive(:changed?).never
        @customer.name = 'bar 2'
        @customer.should be_changed
      end
    end
  end

  describe "attributes_for_persistence" do
    describe "many" do
      before do
        @car = Car.new.tap do |e|
          e.raw_attributes = {:t => [{:a => 0}, {:a => 1}], :n => 'bar'}
        end
      end

      it "should not include nil associations" do
        @car.tire = nil
        @car.attributes_for_persistence.should == {:n => 'bar'}
      end

      it "should not instantiate and use the raw data if not instantiated before" do
        Tire.any_instance.should_receive(:attributes_for_persistence).never
        @car.attributes_for_persistence.should == {:t => [{:a => 0}, {:a => 1}], :n => 'bar'}
      end

      it "should use the changed attributes when instantiated and changed" do
        @car.tire.first.foo = 3
        @car.attributes_for_persistence.should == {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
      end

      it "should use the the replaced attributes" do
        @car.tire = [Tire.new(:foo => 2)]
        @car.attributes_for_persistence.should == {:t => [{:a => 2}], :n => 'bar'}
      end
    end

    describe "one" do
      before do
        @customer = Customer.new.tap do |e|
          e.raw_attributes = {:e => {:a => 'foo'}, :n => 'bar'}
        end
      end

      it "should not include nil associations" do
        @customer.email = nil
        @customer.attributes_for_persistence.should == {:n => 'bar'}
      end

      it "should not instantiate and use the raw data if not instantiated before" do
        Email.any_instance.should_receive(:attributes_for_persistence).never
        @customer.attributes_for_persistence.should == {:e => {:a => 'foo'}, :n => 'bar'}
      end

      it "should use the changed attributes when instantiated and changed" do
        @customer.email.address = "foo 2"
        @customer.attributes_for_persistence.should == {:e => {:a => 'foo 2'}, :n => 'bar'}
      end

      it "should use the the replaced attributes" do
        @customer.email = Email.new(:address => 'foo 2')
        @customer.attributes_for_persistence.should == {:e => {:a => 'foo 2'}, :n => 'bar'}
      end
    end
  end

  describe "reset_associations" do
    before do
      @customer = Customer.new.tap do |e|
        e.raw_attributes = {:e => {:a => 'foo'}, :n => 'bar'}
      end
    end

    it "reset the associations" do
      @customer.email.address
      @customer.email.loaded?.should == true

      @customer.reset_associations
      @customer.email.loaded?.should == false

    end

  end
end

describe Ripple::Association do

  it "should use the :class_name option" do
    association = Ripple::Association.new(:many, :pages, :class_name => "Email")
    association.klass.should == Email
  end

  it "return many proxy when when type is :many" do
    association = Ripple::Association.new(:many, :pages)
    association.proxy_class.should == Ripple::Associations::Many
  end

  it "return one proxy when when type is :one" do
    association = Ripple::Association.new(:one, :pages)
    association.proxy_class.should == Ripple::Associations::One
  end

  it "should be many when type is :many" do
    Ripple::Association.new(:many, :pages).should be_many
  end

  it "should be one when type is :one" do
    Ripple::Association.new(:one, :pages).should be_one
  end

  it "should determine an instance variable based on the name" do
    Ripple::Association.new(:many, :pages).ivar.should == "@_pages"
  end

  it "should return short name if dfeinded" do
    association = Ripple::Association.new(:many, :pages, :short => :f)
    association.short_name.should == :f
  end

  it "should fallback to name if no short name is defined" do
    association = Ripple::Association.new(:many, :pages)
    association.short_name.should == :pages
  end
end