require 'spec_helper'

describe Ripple::Associations::Many do
  it "return nil when the association is not set" do
    Car.new.tire.should === []
  end

  it "should lazy init the association" do
    Ripple::Associations::Many.any_instance.should_receive(:find_target).never

    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
  end

  it "should init the association when used" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
    car.tire.map(&:foo).should == [3,1]
  end

  it "should be able to replace the association with a hash" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
    car.tire.map(&:foo).should == [3,1]

    car.tire = [{:a => 4}, {:a => 5}]
    car.tire.map(&:foo).should == [4,5]
  end


  it "should be apple to replace the association with the association object" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
    car.tire.map(&:foo).should == [3,1]

    car.tire = [Tire.new(:foo => 4), Tire.new(:foo => 5)]
    car.tire.map(&:foo).should == [4,5]
  end

  it "be able to append an object" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}


    car.tire << Tire.new(:foo => 4)
    car.tire.map(&:foo).should == [3,1,4]
  end

  it "should have the parent document" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}

    car.tire.each do |t|
      t.car.should == car
    end
  end
end