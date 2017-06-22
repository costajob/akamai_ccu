require "helper"

describe AkamaiCCU::Wrapper do
  before { AkamaiCCU::Wrapper.setup(Stubs.secret, Stubs::Client) }
  let(:wrapper) { AkamaiCCU::Wrapper.new(endpoint: Stubs::Endpoint.new("staging", "invalidate", "url"), signer_klass: Stubs::Signer, response_klass: Stubs::Response) }

  it "must reuse secret and client" do
    secret = AkamaiCCU::Wrapper.secret
    client = AkamaiCCU::Wrapper.client
    AkamaiCCU::Wrapper.setup(Stubs.secret, Stubs::Client)
    secret.must_be_same_as AkamaiCCU::Wrapper.secret
    client.must_be_same_as AkamaiCCU::Wrapper.client
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

  it "must invalidate contents by url on production" do
    res = AkamaiCCU::Wrapper.invalidate_by_url!(Stubs.urls) do |w|
      w.signer_klass = Stubs::Signer
      w.response_klass = Stubs::Response
    end
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/production;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html\",\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js\"]}"
  end

  it "must delete contents by url on staging" do
    res = AkamaiCCU::Wrapper.delete_by_url(Stubs.urls) do |w|
      w.signer_klass = Stubs::Signer
      w.response_klass = Stubs::Response
    end
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/delete/url/staging;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html\",\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js\"]}"
  end

  it "must invalidate contents by CP code on staging" do
    res = AkamaiCCU::Wrapper.invalidate_by_cpcode(Stubs.cpcodes) do |w|
      w.signer_klass = Stubs::Signer
      w.response_klass = Stubs::Response
    end
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/cpcode/staging;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"12345\",\"98765\"]}"
  end

  it "must delete contents by CP code on production" do
    res = AkamaiCCU::Wrapper.delete_by_cpcode!(Stubs.cpcodes) do |w|
      w.signer_klass = Stubs::Signer
      w.response_klass = Stubs::Response
    end
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/delete/cpcode/production;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"12345\",\"98765\"]}"
  end

  it "must call the client with the specified body and auth header" do
    res = wrapper.call(Stubs.urls)
    res.must_be_instance_of wrapper.response_klass
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/staging;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html\",\"https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js\"]}"
  end
end
