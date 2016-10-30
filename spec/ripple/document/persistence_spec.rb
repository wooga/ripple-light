require 'spec_helper'

describe Ripple::Document::Persistence do
  Ripple.load_configuration('spec/ripple_proxy.yml', [:proxy])

  before do
    class Address
      include Ripple::EmbeddedDocument

      property :street, String, short: 's'
      embedded_in :user
    end

    class User
      include Ripple::Document
      self.bucket_name = 'u'
      self.key_on :key

      property :key, String, short: 'k'
      property :name, String, short: 'n'

      one :address, class_name: 'Address', short: 'a'
    end

    class UserCompressed < User
      def compress?
        true
      end
    end

    @user = User.new
    @user_compressed = UserCompressed.new
    @name = "Chandler"
  end

  it "uses the application/x-snappy content type to serialize the data" do
    @user_compressed.name = @name
    @user_compressed.key = "1"
    @user_compressed.save

    user = User.find("1")
    expect(user.robject.content.content_type).to eq("application/x-snappy")
    expect(user.key).to eq("1")
    expect(user.name).to eq(@name)
  end

  it "does not use the application/x-snappy content type to serialize the data by default" do
    @user.name = @name
    @user.key = "2"
    @user.save

    user = User.find("2")
    expect(user.robject.content.content_type).to eq("application/json")
    expect(user.key).to eq("2")
    expect(user.name).to eq(@name)
  end

  describe "storing and retrieving associations" do
    it "stores associations" do
      @user_compressed.key = "3"
      @user_compressed.name = @name

      address = Address.new
      address.street = "Some street"
      @user_compressed.address = address
      @user_compressed.save

      user = User.find("3")
      expect(user.name).to eq(@name)
      expect(user.key).to eq("3")
      expect(user.address.street).to eq("Some street")
    end
  end
end
