require 'ripple/persistence_proxy'

describe Ripple do
  it "should have a client" do
    Ripple.client.should_not be_nil
  end

  it "should have a unique client per thread" do
    client = Ripple.client
    th = Thread.new { Ripple.client.should_not == client }
    th.join
  end

  it "should be configurable" do
    Ripple.should respond_to(:config)
  end

  it "should allow setting the client manually" do
    Ripple.should respond_to(:client=)
    client = PersistenceProxy::Client.new(pb_port: 9000, host: 'localhost')
    Ripple.client = client
    Ripple.client.should == client
  end

  it "should reset the client when the configuration changes" do
    c = Ripple.client
    Ripple.config = {pb_port: 9000, host: 'localhost'}
    Ripple.client.should_not == c
    Ripple.client.port.should == 9000
  end


  describe "date format" do
    before { @date_format = Ripple.date_format }
    after  { Ripple.date_format = @date_format }

    it "should default to :iso8601" do
      Ripple.date_format.should == :iso8601
    end

    it "should allow setting via the config" do
      Ripple.config = {"date_format" => "rfc822"}
      Ripple.date_format.should == :rfc822
    end

    it "should allow setting manually" do
      Ripple.date_format = "rfc822"
      Ripple.date_format.should == :rfc822
    end
  end
end
