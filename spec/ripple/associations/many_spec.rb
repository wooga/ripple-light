require 'spec_helper'

describe Ripple::Associations::Many do
  it "return nil when the association is not set" do
    expect(Car.new.tire).to eq([])
  end

  it "should lazy init the association" do
    expect_any_instance_of(Ripple::Associations::Many).to receive(:find_target).never

    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
  end

  it "should init the association when used" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
    expect(car.tire.map(&:foo)).to eq([3,1])
  end

  it "should be able to replace the association with a hash" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
    expect(car.tire.map(&:foo)).to eq([3,1])

    car.tire = [{:a => 4}, {:a => 5}]
    expect(car.tire.map(&:foo)).to eq([4,5])
  end


  it "should be apple to replace the association with the association object" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}
    expect(car.tire.map(&:foo)).to eq([3,1])

    car.tire = [Tire.new(:foo => 4), Tire.new(:foo => 5)]
    expect(car.tire.map(&:foo)).to eq([4,5])
  end

  it "be able to append an object" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}


    car.tire << Tire.new(:foo => 4)
    expect(car.tire.map(&:foo)).to eq([3,1,4])
  end

  it "should have the parent document" do
    car = Car.new
    car.raw_attributes = {:t => [{:a => 3}, {:a => 1}], :n => 'bar'}

    car.tire.each do |t|
      expect(t.car).to eq(car)
    end
  end
end
