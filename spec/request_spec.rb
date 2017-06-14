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
end
