require 'spec_helper'

describe Ripple::Document::Key do
  before do
    class Box
      include Ripple::Document
      property :shape, String
    end

    class ShapedBox < Box
      key_on :shape
    end

    @box = Box.new
  end

  it "should define key getter and setter" do
    @box.should respond_to(:key)
    @box.should respond_to(:key=)
  end

  it "should stringify the assigned key" do
    @box.key = 2
    @box.key.should == "2"
  end

  it "should use a property as the key" do
    @box = ShapedBox.new(:shape => "square")
    @box.key.should == "square"
    @box.shape.should == "square"
  end

  it "should raise when try to change an existing key" do
    @box = ShapedBox.new(:shape => 2)
    expect {  @box.key = "bar" }.to raise_error(/key cannot be overwritten: bar - 2/)
  end
end
