require 'spec_helper'

describe "Riak Integration" do
  before(:each) do
    Ripple.load_configuration('spec/riak.yml', [:test])
    Thread.current[:persistence_proxy] = false
    Thread.current[:ripple_client] = nil

    class Address
      include Ripple::EmbeddedDocument

      property :street, String, short: 's'
      embedded_in :user
    end

    class Email
      include Ripple::EmbeddedDocument

      property :address, String, short: 'a'
      embedded_in :user
    end

    class User
      include Ripple::Document
      self.bucket_name = 'u'
      self.key_on :key

      property :key, String, short: 'k'
      property :name, String, short: 'n'

      one :address, class_name: 'Address', short: 'a'

      many :emails, class_name: 'Email', short: 'e'
    end
  end

  after(:each) do
    Thread.current[:persistence_proxy] = nil
    Thread.current[:ripple_client] = nil
  end

  it "can store and fetch an object" do
    user = User.new(key: "123", name: "Chandler Bing")
    user.address = Address.new(street: "Some street")
    user.emails << Email.new(address: 'chandler@bing.com')
    user.emails << Email.new(address: 'chanandler@bong.com')

    expect(user.save).to be true

    user = User.find("123")

    expect(user.name).to eq("Chandler Bing")
    expect(user.address.street).to eq("Some street")
    expect(user.emails.count).to eq(2)
  end

  it "can reload an object from the database" do
    user = User.new(key: "123", name: "Chandler Bing")
    user.address = Address.new(street: "Some street")
    user.emails << Email.new(address: 'chandler@bing.com')
    user.emails << Email.new(address: 'chanandler@bong.com')

    expect(user.save).to be true

    user.name = "Not stored"

    expect(user.reload.name).to eq("Chandler Bing")
  end

  it "can delete an object from the database" do
    user = User.create(key: "123", name: "Chandler Bing")

    user = User.find("123")
    
    expect(user.name).to eq("Chandler Bing")

    expect(user.destroy).to eq(true)

    user = User.find("123")
    expect(user).to be_nil
  end
end
