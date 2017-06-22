require "helper"

describe AkamaiCCU::Secret do
  let(:secret) { AkamaiCCU::Secret.new(client_secret: "xxx=", host: "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", access_token: "akab-access-token-xxx-xxx", client_token: "akab-client-token-xxx-xxx", nonce: "70dc53b8-99a5-4a00-9f04-658eafa437af", time: Time.new(1973,10,29,15,34,12, "+01:00"))}

  it "must factory an instance by tokens file" do
    secret = AkamaiCCU::Secret.by_txt(Stubs.txt_path)
    secret.must_be_instance_of AkamaiCCU::Secret
    secret.host.to_s.must_equal "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/"
    secret.max_body.must_equal 2048
  end

  it "must factory an instance by edgerc file" do
    secret = AkamaiCCU::Secret.by_edgerc(Stubs.edgerc_path)
    secret.must_be_instance_of AkamaiCCU::Secret
    secret.host.to_s.must_equal "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/"
    secret.max_body.must_equal 131072
  end

  it "must skip factory if file does not exist" do
    AkamaiCCU::Secret.by_txt("./noent.txt").must_be_nil
    AkamaiCCU::Secret.by_edgerc("./noent.txt").must_be_nil
  end

  it "must compute signed key" do
    secret.signed_key.must_equal "5o7m4TydQSrLtJ6+GWADiUa5Ttna5IgHr0Y3uot1Y74="
  end

  it "must compute auth header" do
    secret.auth_header.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=19731029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;"
  end

  it "must update timestamp" do
    Time.parse(secret.touch).must_be :>, Time.now - 5
  end

  it "must compute auth header with updated timestamp" do
    timestamp = secret.touch
    secret.auth_header.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=#{timestamp};nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;"
  end

end

