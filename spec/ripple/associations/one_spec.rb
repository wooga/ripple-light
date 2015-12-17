require 'spec_helper'

describe Ripple::Associations::One do

  it "return nil when the association is not set" do
    Customer.new.email.should === nil
  end

  it "return the association when set" do
    email    = Email.new
    customer = Customer.new
    customer.email = email
    customer.email.should === email
  end

  it "should lazy init the association" do
    Ripple::Associations::One.any_instance.should_receive(:find_target).never

    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}
  end

  it "should init the association when used" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}

    customer.email.address.should == 'foo'
  end

  it "should be able to replace the association with a hash" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}
    customer.email.address.should == 'foo'

    customer.email = {:a => 'foo 2'}
    customer.email.address.should == 'foo 2'
  end


  it "should be apple to replace the association with the association object" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}
    customer.email.address.should == 'foo'

    customer.email = Email.new(:address => 'foo 2')
    customer.email.address.should == 'foo 2'
  end

  it "should have the parent document" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}

    customer.email.customer.should == customer
  end

end
