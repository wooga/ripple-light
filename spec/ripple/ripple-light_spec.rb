
describe Ripple do
  it "should have a client" do
    expect(Ripple.client).to be_kind_of(Riak::Client)
  end

  it "should have a unique client per thread" do
    client = Ripple.client
    th = Thread.new { expect(Ripple.client).to_not eq(client) }
    th.join
  end

  it "should be configurable" do
    expect(Ripple).to respond_to(:config)
  end

  it "should allow setting the client manually" do
    expect(Ripple).to respond_to(:client=)
    client = Riak::Client.new(:http_port => 9000)
    Ripple.client = client
    expect(Ripple.client).to be(client)
  end

  it "should reset the client when the configuration changes" do
    c = Ripple.client
    Ripple.config = {:http_port => 9000}
    expect(Ripple.client).to_not eq(c)
    expect(Ripple.client.node.http_port).to eq(9000)
  end


  describe "date format" do
    before { @date_format = Ripple.date_format }
    after  { Ripple.date_format = @date_format }

    it "should default to :iso8601" do
      expect(Ripple.date_format).to eq(:iso8601)
    end

    it "should allow setting via the config" do
      Ripple.config = {"date_format" => "rfc822"}
      expect(Ripple.date_format).to eq(:rfc822)
    end

    it "should allow setting manually" do
      Ripple.date_format = "rfc822"
      expect(Ripple.date_format).to eq(:rfc822)
    end
  end
end
