require "helper"

describe AkamaiCCU::Secret do
  let(:secret) { AkamaiCCU::Secret.new(client_secret: "xxx=", host: "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", access_token: "akab-access-token-xxx-xxx", client_token: "akab-client-token-xxx-xxx", nonce: "70dc53b8-99a5-4a00-9f04-658eafa437af", time: Time.new(1973,10,29,15,34,12, "+01:00"))}

  it "must generate timestamp as a string" do
    AkamaiCCU::Secret.format_utc(Time.new(2017,1,1,15,30,20, "+01:00")).must_equal "20170101T14:30:20+0000"
  end

  it "must sign by digest" do
    AkamaiCCU::Secret.sign("my_data").must_equal "4fQDOPZLl0qzjYcR1R2OhIYRqoyp+NTf2tCmHDCneqw="
  end

  it "must sign by HMAC digest" do
    AkamaiCCU::Secret.sign_HMAC("my_key", "my_data").must_equal "cgT5WPnSQ+4Ucq2Sd0iReNUllb0URgEkCOxqO8tCohI="
  end

  it "must factory an instance by tokens file" do
    secret = AkamaiCCU::Secret.by_file(Stubs.txt_path)
    secret.must_be_instance_of AkamaiCCU::Secret
    secret.host.to_s.must_equal "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/"
    secret.max_body.must_equal 131072
  end

  it "must factory an instance by edgerc file" do
    secret = AkamaiCCU::Secret.by_file(Stubs.edgerc_path)
    secret.must_be_instance_of AkamaiCCU::Secret
    secret.host.to_s.must_equal "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/"
    secret.max_body.must_equal 131072
  end

  it "must skip factory if file does not exist" do
    AkamaiCCU::Secret.by_file("./noent.txt").must_be_nil
  end

  it "must raise an error for file with bad content" do
    -> { AkamaiCCU::Secret.by_file(Stubs.bulk_invalid) }.must_raise AkamaiCCU::Secret::FileContentError
  end

  it "must compute signed key" do
    secret.signed_key.must_equal "5o7m4TydQSrLtJ6+GWADiUa5Ttna5IgHr0Y3uot1Y74="
  end

  it "must compute auth header" do
    secret.auth_header.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=19731029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;"
  end

  it "must update timestamp and nonce" do
    old_nonce = secret.nonce
    secret.touch
    secret.nonce.must_be :!=, old_nonce
    Time.parse(secret.timestamp).must_be :>, Time.now - 5
  end

  it "must compute auth header with updated timestamp and nonce" do
    secret.touch
    secret.auth_header.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=#{secret.timestamp};nonce=#{secret.nonce};"
  end
end

