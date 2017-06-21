require "helper"

describe AkamaiCCU::Endpoint do
  let(:endpoint) { AkamaiCCU::Endpoint.new("production", "invalidate", "cpcode") }

  it "must set some constants" do
    AkamaiCCU::Endpoint::Network::STAGING.must_equal "staging"
    AkamaiCCU::Endpoint::Network::PRODUCTION.must_equal "production"
    AkamaiCCU::Endpoint::Action::INVALIDATE.must_equal "invalidate"
    AkamaiCCU::Endpoint::Action::DELETE.must_equal "delete"
    AkamaiCCU::Endpoint::Mode::URL.must_equal "url"
    AkamaiCCU::Endpoint::Mode::CPCODE.must_equal "cpcode"
  end

  it "must factory instance by constant names" do
    endpoint = AkamaiCCU::Endpoint.by_constants(:PRODUCTION, :DELETE, :CPCODE)
    endpoint.must_be_instance_of AkamaiCCU::Endpoint
    endpoint.network.must_equal AkamaiCCU::Endpoint::Network::PRODUCTION
    endpoint.action.must_equal AkamaiCCU::Endpoint::Action::DELETE
    endpoint.mode.must_equal AkamaiCCU::Endpoint::Mode::CPCODE
  end

  it "must factory instance by name" do
    endpoint = AkamaiCCU::Endpoint.by_name("invalidate_by_cpcode!")
    endpoint.must_be_instance_of AkamaiCCU::Endpoint
    endpoint.network.must_equal AkamaiCCU::Endpoint::Network::PRODUCTION  
    endpoint.action.must_equal AkamaiCCU::Endpoint::Action::INVALIDATE
    endpoint.mode.must_equal AkamaiCCU::Endpoint::Mode::CPCODE
    endpoint = AkamaiCCU::Endpoint.by_name("delete_by_url")
    endpoint.must_be_instance_of AkamaiCCU::Endpoint
    endpoint.network.must_equal AkamaiCCU::Endpoint::Network::STAGING
    endpoint.action.must_equal AkamaiCCU::Endpoint::Action::DELETE
    endpoint.mode.must_equal AkamaiCCU::Endpoint::Mode::URL
  end

  it "must be represented as a string" do
    endpoint.to_s.must_equal "invalidate_by_cpcode!"
  end

  it "must build the endpoint path" do
    endpoint.path.must_equal "/ccu/v3/invalidate/cpcode/production"
  end
end
