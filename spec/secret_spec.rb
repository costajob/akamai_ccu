require "helper"

describe AkamaiCCU::Secret do
  let(:secret) { AkamaiCCU::Secret.new(client_secret: "xxx=", host: "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", access_token: "akab-access-token-xxx-xxx", client_token: "akab-client-token-xxx-xxx", nonce: "70dc53b8-99a5-4a00-9f04-658eafa437af", time: Time.new(2017,10,29,15,34,12))}

  it "must compute signed key" do
    secret.signed_key.must_equal "CXEjELdQCdrniM6/KDrQ5aMeWF1MSKfRGy8v3+/bdPU="
  end

  it "must compute auth header" do
    secret.auth_header.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;"
  end
end

