require "helper"

describe AkamaiCCU::Request do
  let(:request) { AkamaiCCU::Request.new(raw: Stubs.raw, secret: Stubs.secret, headers: Stubs.headers)}

  it "must compute canonical headers" do
    request.send(:canonical_headers).must_equal ["accept:*/*", "user-agent:Ruby"]
  end

  it "must return empty array for no headers" do
    request = AkamaiCCU::Request.new(raw: Stubs.raw, secret: Stubs.secret)
    request.send(:canonical_headers).must_be_empty
  end

  it "must compute signed_body" do
    request.send(:signed_body).must_equal "VtM4tPIn4xfIevRV/gaYHUFUGajmmLVbWyDig5YTvWw="
  end

  it "must truncate body if max_len is exceeded" do
    secret = Stubs.secret
    secret.max_body = 5
    request = AkamaiCCU::Request.new(raw: Stubs.raw, secret: secret, headers: Stubs.headers)
    request.send(:signed_body).must_equal "4upmIm1CU/hXuh40MnLbUILLYD1sRi7D8UrKHmCRxWA="
  end

  it "must skip signing if body is nil" do
    raw = Stubs.raw
    raw.body = nil
    request = AkamaiCCU::Request.new(raw: raw, secret: Stubs.secret, headers: Stubs.headers)
    request.send(:signed_body).must_be_empty
  end

  it "must skip signing if body is not permitted" do
    raw = Stubs.raw
    raw.body_permitted = false
    request = AkamaiCCU::Request.new(raw: raw, secret: Stubs.secret, headers: Stubs.headers)
    request.send(:signed_body).must_be_empty
  end

  it "must compute signature data" do
    request.send(:signature_data).must_equal ["POST", "https", "www.ruby-lang.org", "/", "accept:*/*\tuser-agent:Ruby", "VtM4tPIn4xfIevRV/gaYHUFUGajmmLVbWyDig5YTvWw=", "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;"]
  end

  it "must compute signed headers" do
    request.send(:signed_headers).must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=cRApERvZzgA/uDD6U5XJEDkdiXDrawMJorqMdGFpRUM="
  end

  it "must decorate original request" do
    request.decorate.tap do |req|
      req.must_be_instance_of Stubs::Raw
      req.keys.must_include "Authorization"
    end
  end
end
