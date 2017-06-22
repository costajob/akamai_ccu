require "helper"

describe AkamaiCCU::Client do
  let(:client) { AkamaiCCU::Client.new(host: Stubs.host, net_klass: Stubs::HTTP) }

  it "must execute request method on GET" do
    res = client.call(method: AkamaiCCU::GET, initheader: nil)
    res.body.must_equal "method=Stubs::HTTP::Get;uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;initheader=nil"
  end

  it "must execute request method on POST" do
    res = client.call do |request|
      request.body = { hostname: "bc.akamaiapibootcamp.com", objects: Stubs.urls }.to_json
    end
    res.body.must_equal "method=Stubs::HTTP::Post;uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;initheader={\"Content-Type\"=>\"application/json\"};body=\"{\\\"hostname\\\":\\\"bc.akamaiapibootcamp.com\\\",\\\"objects\\\":[\\\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html\\\",\\\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js\\\"]}\""
  end
end
