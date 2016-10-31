require 'spec_helper'

describe Ripple::Associations::One do

  it "return nil when the association is not set" do
    expect(Customer.new.email).to be_nil
  end

  it "return the association when set" do
    email    = Email.new
    customer = Customer.new
    customer.email = email

    expect(customer.email).to eq(email)
  end

  it "should lazy init the association" do
    expect_any_instance_of(Ripple::Associations::One).to receive(:find_target).never

    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}
  end

  it "should init the association when used" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}

    expect(customer.email.address).to eq('foo')
  end

  it "should be able to replace the association with a hash" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}
    expect(customer.email.address).to eq('foo')

    customer.email = {:a => 'foo 2'}
    expect(customer.email.address).to eq('foo 2')
  end


  it "should be apple to replace the association with the association object" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}
    expect(customer.email.address).to eq('foo')

    customer.email = Email.new(:address => 'foo 2')
    expect(customer.email.address).to eq('foo 2')
  end

  it "should have the parent document" do
    customer = Customer.new
    customer.raw_attributes = {:e => {:a => 'foo'}}

    expect(customer.email.customer).to eq(customer)
  end
end
