require "helper"

describe AkamaiCCU::Request do
  let(:request_post) { AkamaiCCU::Request.new(raw: Stubs.post, secret: Stubs.secret, headers: Stubs.headers) }
  let(:request_get) { AkamaiCCU::Request.new(raw: Stubs.get, secret: Stubs.secret, headers: Stubs.headers) }
  let(:request_no_headers) { AkamaiCCU::Request.new(raw: Stubs.post, secret: Stubs.secret) }
  let(:request_short) { AkamaiCCU::Request.new(raw: Stubs.post, secret: Stubs.short_secret, headers: Stubs.headers) }
  let(:request_no_body) { AkamaiCCU::Request.new(raw: Stubs.no_body, secret: Stubs.secret, headers: Stubs.headers) }

  it "must return a decorated request instance" do
    [request_post, request_get, request_no_headers, request_short, request_no_body].each do |request|
      req = request.decorate
      req.must_be_instance_of Stubs::Raw
      req.keys.must_include "Authorization"
    end
  end

  it "must decorate original post request" do
    req = request_post.decorate
    req.keys["Authorization"].must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=WCmS/lAStnGqKAX6lVmwbAQxNxxVDnFsT6c7FwQq/+k="
  end

  it "must decorate original get request" do
    req = request_get.decorate
    req.keys["Authorization"].must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=+5zVz/sorkKbtvGHonrO0njfcoG7Gg5kuB+WibP14yg="
  end

  it "must decorate original no headers request" do
    req = request_no_headers.decorate
    req.keys["Authorization"].must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=ZpqvK3SGBpHsLWIRqN2oMIzumwBMZqVyt4fRqoOjTVc="
  end

  it "must decorate original request by sign truncated body" do
    req = request_short.decorate
    req.keys["Authorization"].must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=VANjLg5RQ/UaJXYBhqr4HPFM5ZeAM0aZCUfd9yuAMnQ="
  end

  it "must decorate original no-body request" do
    req = request_no_body.decorate
    req.keys["Authorization"].must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=PEAjVN0pGQrjYbuMI7xVlzxOReniqqr+2qyv0i5fGQs="
  end
end
