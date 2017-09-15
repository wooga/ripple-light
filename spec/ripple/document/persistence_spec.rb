require 'spec_helper'

describe Ripple::Document::Persistence do
  before do
    class User
      include Ripple::Document
      self.bucket_name = 'u'
      property :text, String, short: 't'

    end

    class UserCompressed < User
      def compress?
        true
      end
    end

    @user = User.new
    @user_comressed = UserCompressed.new

    expect_any_instance_of(Riak::RObject).to receive(:store) { true }
  end

  it "uses the application/x-snappy content type to serialize the data" do
    text = "a"
    @user_comressed.text = text
    @user_comressed.save

    expect(@user_comressed.robject.content.content_type).to eq("application/x-snappy")
    expect(@user_comressed.robject.content.data).to eq({ t: text })
  end

  it "does not use the application/x-snappy content type to serialize the data by default" do
    text = "a"
    @user.text = text
    @user.save

    expect(@user.robject.content.content_type).to eq("application/json")
    expect(@user.robject.content.data).to eq({ t: text })
  end
end
