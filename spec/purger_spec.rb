require "helper"

describe AkamaiCCU::Purger do
  let(:purger) { AkamaiCCU::Purger.new(secret: Stubs.secret, client_klass: Stubs::Client, req_klass: Stubs::Decorator) }

  it "must call the client with the specified body and auth header" do
    res = purger.call(host: "bc.akamaiapibootcamp.com", objects: %w[/index.html /homepage.html])
    res.must_equal "host: akaa-baseurl-xxx-xxx.luna.akamaiapis.net/; body: {\"hostname\":\"bc.akamaiapibootcamp.com\",\"objects\":[\"/index.html\",\"/homepage.html\"]}; auth: EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=ZzUq6DYRJ9hZTDkAMPigr5dzqSG9lOpudYdFjxlrbNY="
  end
end
