require "helper"

describe AkamaiCCU::Client do
  let(:client) { AkamaiCCU::Client.new(host: Stubs.host, net_klass: Stubs::HTTP) }

  it "must set HTTP use_ssl and verify mode" do
    http = client.send(:http)
    http.use_ssl.must_equal true
    http.verify_mode.must_equal OpenSSL::SSL::VERIFY_PEER
  end

  it "must execute request method on GET" do
    res = client.call(path: "ccu/v3/diagnosis", method: AkamaiCCU::Client::GET, initheader: nil)
    res.body.must_equal "method=Stubs::HTTP::Get;uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/diagnosis;initheader=nil"
  end

  it "must execute request method on POST" do
    res = client.call(path: "ccu/v3/invalidate/url/staging") do |request|
      request.body = { hostname: "bc.akamaiapibootcamp.com", objects: Stubs.urls }.to_json
    end
    res.body.must_equal "method=Stubs::HTTP::Post;uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/staging;initheader={\"Content-Type\"=>\"application/json\"};body=\"{\\\"hostname\\\":\\\"bc.akamaiapibootcamp.com\\\",\\\"objects\\\":[\\\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html\\\",\\\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js\\\"]}\""
  end
end
