require 'spec_helper'

describe Ripple::Document::Persistence do
  before do
    class User
      include Ripple::Document
      self.bucket_name = 'u'
      property :text, String, short: 't'
    end

    @user = User.new
  end

  it "should compress the data if larger than MAX_JSON_SIZE" do
    text = "a" * Ripple::Document::Persistence::MAX_JSON_SIZE
    @user.text = text
    @user.save

    @user.robject.content.content_type.should == "application/x-snappy"
    @user.robject.content.data.should == { "t" => text }

    text = "a" * (Ripple::Document::Persistence::MAX_JSON_SIZE / 2)
    @user.text = text
    @user.save

    @user.robject.content.content_type.should == "application/json"
    @user.robject.content.data.should == { "t" => text }
  end
end
