require "helper"

describe AkamaiCCU::Client do
  let(:client) { AkamaiCCU::Client.new(host: Stubs.host, net_klass: Stubs::HTTP) }

  it "must execute request method on GET" do
    res = client.call(method: AkamaiCCU::GET, initheader: nil)
    res.body.must_equal "response: Stubs::HTTP::Get: uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url; initheader=nil"
  end

  it "must execute request method on POST" do
    res = client.call do |request|
      request.body = { hostname: "bc.akamaiapibootcamp.com", objects: %w[/index.html /homepage.html] }.to_json
    end
    res.body.must_equal "response: Stubs::HTTP::Post: uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url; initheader={\"Content-Type\"=>\"application/json\"}; body=\"{\\\"hostname\\\":\\\"bc.akamaiapibootcamp.com\\\",\\\"objects\\\":[\\\"/index.html\\\",\\\"/homepage.html\\\"]}\""
  end
end
