require "helper"

describe AkamaiCCU::Wrapper do
  it "must set some constants" do
    AkamaiCCU::Wrapper::Network::STAGING.must_equal "staging"
    AkamaiCCU::Wrapper::Network::PRODUCTION.must_equal "production"
    AkamaiCCU::Wrapper::Action::INVALIDATE.must_equal "invalidate"
    AkamaiCCU::Wrapper::Action::DELETE.must_equal "delete"
    AkamaiCCU::Wrapper::Mode::URL.must_equal "url"
    AkamaiCCU::Wrapper::Mode::CPCODE.must_equal "cpcode"
  end

  it "must call the client with the specified body and auth header" do
    wrapper = AkamaiCCU::Wrapper.new(secret: Stubs.secret, client_klass: Stubs::Client, signer_klass: Stubs::Signer)
    res = wrapper.call(%w[https://bc.akamaiapibootcamp.com/index.html https://bc.akamaiapibootcamp.com/homepage.html])
    res.must_equal "host: akaa-baseurl-xxx-xxx.luna.akamaiapis.net/; path: /ccu/v3/invalidate/url/staging; body: {\"objects\":[\"https://bc.akamaiapibootcamp.com/index.html\",\"https://bc.akamaiapibootcamp.com/homepage.html\"]}; auth: EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=ZzUq6DYRJ9hZTDkAMPigr5dzqSG9lOpudYdFjxlrbNY="
  end

  it "must provide API class methods" do
    AkamaiCCU::Wrapper.must_respond_to :invalidate_by_url
    AkamaiCCU::Wrapper.must_respond_to :invalidate_by_cpcode
    AkamaiCCU::Wrapper.must_respond_to :delete_by_url
    AkamaiCCU::Wrapper.must_respond_to :delete_by_cpcode
    AkamaiCCU::Wrapper.must_respond_to :invalidate_by_url!
    AkamaiCCU::Wrapper.must_respond_to :invalidate_by_cpcode!
    AkamaiCCU::Wrapper.must_respond_to :delete_by_url!
    AkamaiCCU::Wrapper.must_respond_to :delete_by_cpcode!
  end
end
