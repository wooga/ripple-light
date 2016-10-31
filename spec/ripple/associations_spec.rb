require 'spec_helper'

describe Ripple::Associations do

  it "should provide access to the associations hash" do
    expect(Customer).to respond_to(:associations)
    expect(Customer.associations).to be_kind_of(Hash)
  end

  describe "when adding a :many association" do
    it "should add accessor and mutator methods" do
      Customer.many :foos, :class_name => 'Email'
      expect(Customer.instance_methods.map(&:to_sym)).to include(:foos)
      expect(Customer.instance_methods.map(&:to_sym)).to include(:foos=)
    end
  end

  describe "when adding a :one association" do
    it "should add accessor, mutator, and query methods" do
      Customer.one :foo, :class_name => 'Email'
      expect(Customer.instance_methods.map(&:to_sym)).to include(:foo)
      expect(Customer.instance_methods.map(&:to_sym)).to include(:foo=)
      expect(Customer.instance_methods.map(&:to_sym)).to include(:foo?)
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
        expect(@car).not_to be_changed
      end

      it "should return false if the asscociation has been loaded but not modified" do
        expect(@car.tire.first.foo).to eq(0)
        expect(@car).not_to be_changed
      end

      it "should return true if the asscociation has been loaded and is modified" do
        @car.tire.first.foo = 2
        expect(@car).to be_changed
      end

      it "should return true if the asscociation has been added" do
        @car.tire << Tire.new(:foo => 2)
        expect(@car).to be_changed
      end

      it "should not evaluate associations when the base class has been changed" do
        expect_any_instance_of(Tire).to receive(:changed?).never
        @car.name = 'bar 2'
        expect(@car).to be_changed
      end

      it "should return true if a element has been deleted" do
        @car.tire.reject!{|f| f.foo == 1}
        expect(@car).to be_changed
        expect(@car.tire.length).to eq(1)
      end
    end

    describe "one" do
      before do
        @customer = Customer.new.tap do |e|
          e.raw_attributes = {:e => {:a => 'foo'}, :n => 'bar'}
        end
      end

      it "should return false if the asscociation has not been loaded" do
        expect(@customer).not_to be_changed
      end

      it "should return false if the asscociation has been loaded but not modified" do
        expect(@customer.email.address).to eq('foo')
        expect(@customer).not_to be_changed
      end

      it "should return true if the asscociation has been loaded and is modified" do
        @customer.email.address = 'new foo'
        expect(@customer).to be_changed
      end

      it "should return true if the asscociation has been replaced" do
        @customer.email = Email.new
        expect(@customer).to be_changed
      end

      it "should not evaluate associations when the base class has been changed" do
        expect_any_instance_of(Email).to receive(:changed?).never
        @customer.name = 'bar 2'
        expect(@customer).to be_changed
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
        expect(@car.attributes_for_persistence).to eq({:n => 'bar'})
      end

      it "should not instantiate and use the raw data if not instantiated before" do
        expect_any_instance_of(Tire).to receive(:attributes_for_persistence).never
        expect(@car.attributes_for_persistence).to eq({:t => [{:a => 0}, {:a => 1}], :n => 'bar'})
      end

      it "should use the changed attributes when instantiated and changed" do
        @car.tire.first.foo = 3
        expect(@car.attributes_for_persistence).to eq({:t => [{:a => 3}, {:a => 1}], :n => 'bar'})
      end

      it "should use the the replaced attributes" do
        @car.tire = [Tire.new(:foo => 2)]
        expect(@car.attributes_for_persistence).to eq({:t => [{:a => 2}], :n => 'bar'})
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
        expect(@customer.attributes_for_persistence).to eq({:n => 'bar'})
      end

      it "should not instantiate and use the raw data if not instantiated before" do
        expect_any_instance_of(Email).to receive(:attributes_for_persistence).never
        expect(@customer.attributes_for_persistence).to eq({:e => {:a => 'foo'}, :n => 'bar'})
      end

      it "should use the changed attributes when instantiated and changed" do
        @customer.email.address = "foo 2"
        expect(@customer.attributes_for_persistence).to eq({:e => {:a => 'foo 2'}, :n => 'bar'})
      end

      it "should use the the replaced attributes" do
        @customer.email = Email.new(:address => 'foo 2')
        expect(@customer.attributes_for_persistence).to eq({:e => {:a => 'foo 2'}, :n => 'bar'})
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
      expect(@customer.email.loaded?).to be true

      @customer.reset_associations
      expect(@customer.email.loaded?).to be false
    end
  end
end

describe Ripple::Association do

  it "should use the :class_name option" do
    association = Ripple::Association.new(:many, :pages, :class_name => "Email")
    expect(association.klass).to eq(Email)
  end

  it "return many proxy when when type is :many" do
    association = Ripple::Association.new(:many, :pages)
    expect(association.proxy_class).to eq(Ripple::Associations::Many)
  end

  it "return one proxy when when type is :one" do
    association = Ripple::Association.new(:one, :pages)
    expect(association.proxy_class).to eq(Ripple::Associations::One)
  end

  it "should be many when type is :many" do
    expect(Ripple::Association.new(:many, :pages)).to be_many
  end

  it "should be one when type is :one" do
    expect(Ripple::Association.new(:one, :pages)).to be_one
  end

  it "should determine an instance variable based on the name" do
    expect(Ripple::Association.new(:many, :pages).ivar).to eq("@_pages")
  end

  it "should return short name if dfeinded" do
    association = Ripple::Association.new(:many, :pages, :short => :f)
    expect(association.short_name).to eq(:f)
  end

  it "should fallback to name if no short name is defined" do
    association = Ripple::Association.new(:many, :pages)
    expect(association.short_name).to eq(:pages)
  end
end
