require 'spec_helper'

describe Ripple::Document::Persistence do
  before do
    class User
      include Ripple::Document
      self.bucket_name = 'u'
      property :text, String, short: 't'

      def compress?
        true
      end
    end

    @user = User.new
  end

  it "uses the application/x-snappy content type to serialize the data" do
    text = "a"
    @user.text = text
    @user.save

    @user.robject.content.content_type.should == "application/x-snappy"
    @user.robject.content.data.should == { "t" => text }
  end
end
