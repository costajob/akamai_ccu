require "helper"

describe AkamaiCCU::Wrapper do
  let(:objects) { %w[https://bc.akamaiapibootcamp.com/index.html https://bc.akamaiapibootcamp.com/homepage.html] }
  let(:wrapper) { AkamaiCCU::Wrapper.new(secret: Stubs.secret, client_klass: Stubs::Client, signer_klass: Stubs::Signer, response_klass: Stubs::Response) }

  describe AkamaiCCU::Wrapper::API do
    let(:api) { AkamaiCCU::Wrapper::API.new("production", "invalidate", "cpcode") }

    it "must set some constants" do
      AkamaiCCU::Wrapper::API::Network::STAGING.must_equal "staging"
      AkamaiCCU::Wrapper::API::Network::PRODUCTION.must_equal "production"
      AkamaiCCU::Wrapper::API::Action::INVALIDATE.must_equal "invalidate"
      AkamaiCCU::Wrapper::API::Action::DELETE.must_equal "delete"
      AkamaiCCU::Wrapper::API::Mode::URL.must_equal "url"
      AkamaiCCU::Wrapper::API::Mode::CPCODE.must_equal "cpcode"
    end

    it "must return default instance" do
      default = AkamaiCCU::Wrapper::API.default
      default.must_be_instance_of AkamaiCCU::Wrapper::API
      default.network.must_equal AkamaiCCU::Wrapper::API::Network::STAGING
      default.action.must_equal AkamaiCCU::Wrapper::API::Action::INVALIDATE
      default.mode.must_equal AkamaiCCU::Wrapper::API::Mode::URL
    end

    it "must factory instance by constant names" do
      api = AkamaiCCU::Wrapper::API.by_constants(:PRODUCTION, :DELETE, :CPCODE)
      api.must_be_instance_of AkamaiCCU::Wrapper::API
      api.network.must_equal AkamaiCCU::Wrapper::API::Network::PRODUCTION
      api.action.must_equal AkamaiCCU::Wrapper::API::Action::DELETE
      api.mode.must_equal AkamaiCCU::Wrapper::API::Mode::CPCODE
    end

    it "must be represented as a string" do
      api.to_s.must_equal "invalidate_by_cpcode!"
    end

    it "must build the endpoint path" do
      api.path.must_equal "/ccu/v3/invalidate/cpcode/production"
    end
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

  it "must accept a block to edit wrapper attributes" do
    res = AkamaiCCU::Wrapper.invalidate_by_url!(objects) do |w|
      w.secret = Stubs.secret
      w.client_klass = Stubs::Client
      w.signer_klass = Stubs::Signer
      w.response_klass = Stubs::Response
    end
    res.must_be_instance_of Stubs::Response
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/production;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://bc.akamaiapibootcamp.com/index.html\",\"https://bc.akamaiapibootcamp.com/homepage.html\"]}"
  end

  it "must return a bening value when no objects are specified" do
    wrapper.call.must_equal :missing_objects
  end

  it "must return a bening value when no secret is specified" do
    wrapper.secret = nil
    wrapper.call(objects).must_equal :missing_secret
  end

  it "must call the client with the specified body and auth header" do
    res = wrapper.call(objects)
    res.must_be_instance_of wrapper.response_klass
    res.to_s.must_equal "uri=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/ccu/v3/invalidate/url/staging;request=method=POST;path=https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/;headers=accept-encoding,accept,user-agent,Authorization;body={\"objects\":[\"https://bc.akamaiapibootcamp.com/index.html\",\"https://bc.akamaiapibootcamp.com/homepage.html\"]}"
  end
end
