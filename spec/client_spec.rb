require "helper"

describe AkamaiCCU::Client do
  let(:client) { AkamaiCCU::Client.new(secret: Stubs.secret, net_klass: Stubs::HTTP) }

  it "must execute request method on GET" do
    res = client.call(path: "en/downloads", initheader: AkamaiCCU::JSON_CONTENT)
    res.body.must_equal "response: Stubs::HTTP::Get: uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/en/downloads; initheader={\"Content-Type\"=>\"application/json\"}"
  end

  it "must execute request method on POST" do
    res = client.call(path: "en/downloads", method: AkamaiCCU::POST, initheader: AkamaiCCU::JSON_CONTENT) do |request|
      request.body = {"name"=>"Ruby", "version"=>"2.4.1", "date"=>"2016-12-25"}.to_json
    end
    res.body.must_equal "response: Stubs::HTTP::Post: uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/en/downloads; initheader={\"Content-Type\"=>\"application/json\"}; body=\"{\\\"name\\\":\\\"Ruby\\\",\\\"version\\\":\\\"2.4.1\\\",\\\"date\\\":\\\"2016-12-25\\\"}\""
  end
end
