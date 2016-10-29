require 'spec_helper'

describe Ripple::Document::Persistence do
  Ripple.load_configuration('spec/ripple_proxy.yml', [:proxy])

  before do
    class User
      include Ripple::Document
      self.bucket_name = 'u'
      self.key_on :key

      property :key, String, short: 'k'
      property :text, String, short: 't'

    end

    class UserCompressed < User
      def compress?
        true
      end
    end

    @user = User.new
    @user_comressed = UserCompressed.new
  end

  it "uses the application/x-snappy content type to serialize the data" do
    text = "a"
    @user_comressed.text = text
    @user_comressed.key = "1"
    @user_comressed.save

    @user_comressed.robject.content.content_type.should == "application/x-snappy"
    @user_comressed.robject.content.data.should == { "t" => text, "k" => "1" }
  end

  it "does not use the application/x-snappy content type to serialize the data by default" do
    text = "a"
    @user.text = text
    @user.key = "1"
    @user.save

    @user.robject.content.content_type.should == "application/json"
    @user.robject.content.data.should == { "t" => text, "k" => "1" }
  end
end
