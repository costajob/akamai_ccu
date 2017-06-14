require "helper"

describe AkamaiCCU::Secret do
  let(:secret) { AkamaiCCU::Secret.new(client_secret: "xxx=", host: "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", access_token: "akab-access-token-xxx-xxx", client_token: "akab-client-token-xxx-xxx", nonce: "70dc53b8-99a5-4a00-9f04-658eafa437af")}

  it "must compute signed key" do
    secret.signed_key.size.must_equal 44
  end

  it "must compute auth header" do
    secret.auth_header.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20170614T14:01:40+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;"
  end
end

