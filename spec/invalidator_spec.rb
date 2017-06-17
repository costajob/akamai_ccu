require "helper"

describe AkamaiCCU::Invalidator do
  it "must call the client with the specified body and auth header" do
    invalidator = AkamaiCCU::Invalidator.new(hostname: "bc.akamaiapibootcamp.com", secret: Stubs.secret, client_klass: Stubs::Client, signer_klass: Stubs::Signer)
    res = invalidator.call(objects: %w[/index.html /homepage.html])
    res.must_equal "host: akaa-baseurl-xxx-xxx.luna.akamaiapis.net/; path: /ccu/v3/invalidate/url; body: {\"hostname\":\"bc.akamaiapibootcamp.com\",\"objects\":[\"/index.html\",\"/homepage.html\"]}; auth: EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=ZzUq6DYRJ9hZTDkAMPigr5dzqSG9lOpudYdFjxlrbNY="
  end
end
