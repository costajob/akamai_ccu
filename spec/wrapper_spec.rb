require "helper"

describe AkamaiCCU::Wrapper do
  let(:objects) { %w[https://bc.akamaiapibootcamp.com/index.html https://bc.akamaiapibootcamp.com/homepage.html] }
  let(:wrapper) { AkamaiCCU::Wrapper.new(secret: Stubs.secret, endpoint: Stubs::Endpoint.new("ccu/v3/invalidate/url/staging"), client_klass: Stubs::Client, signer_klass: Stubs::Signer, response_klass: Stubs::Response) }

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

  it "must accept a block to edit wrapper attributes" do
    res = AkamaiCCU::Wrapper.invalidate_by_url!(objects, Stubs.secret) do |w|
      w.client_klass = Stubs::Client
      w.signer_klass = Stubs::Signer
      w.response_klass = Stubs::Response
    end
    res.must_be_instance_of Stubs::Response
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/production;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://bc.akamaiapibootcamp.com/index.html\",\"https://bc.akamaiapibootcamp.com/homepage.html\"]}"
  end

  it "must return early when no objects are specified" do
    wrapper.call.must_be_nil
  end

  it "must call the client with the specified body and auth header" do
    res = wrapper.call(objects)
    res.must_be_instance_of wrapper.response_klass
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/staging;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://bc.akamaiapibootcamp.com/index.html\",\"https://bc.akamaiapibootcamp.com/homepage.html\"]}"
  end

  it "must allow changing the endpoint to swith API" do
    wrapper.endpoint = Stubs::Endpoint.new("ccu/v3/delete/cpcode/production")
    res = wrapper.call(objects)
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/delete/cpcode/production;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://bc.akamaiapibootcamp.com/index.html\",\"https://bc.akamaiapibootcamp.com/homepage.html\"]}"
  end
end
