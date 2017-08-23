require "helper"

describe AkamaiCCU::Response do
  let(:error) { AkamaiCCU::Response.new(Stubs.error_body) }
    let(:ack) { AkamaiCCU::Response.new(Stubs.ack_body, Time.new(2017,6,20,12,19,11, "+01:00")) }

  it "must accept a plain Hash as the body" do
    response = AkamaiCCU::Response.new("status"=>201)
    response.successful?.must_equal true
  end

  it "must accept a JSON string as the body" do
    response = AkamaiCCU::Response.new({ "status"=>201 }.to_json)
    response.successful?.must_equal true
  end

  it "must represent error as a string" do
    error = AkamaiCCU::Response.new(Stubs.error_body)
    error.to_s.must_equal "status=403; title=unauthorized cpcode; detail=12345; support_id=17PY1498401498349113-269829312; described_by=https://api.ccu.akamai.com/ccu/v2/errors/unauthorized-cpcode"
  end

  it "must represent ack as a string" do
    ack = AkamaiCCU::Response.new(Stubs.ack_body, Time.new(2017,6,20,12,19,11, "+01:00"))
    ack.to_s.must_equal "status=201; detail=Request accepted; support_id=17PY1498402073417329-261436608; purge_id=44ac266e-59b5-11e7-84ca-75d9dd540c3b; copletion_at=2017-06-20 12:19:16 +0100"
  end

  it "must return a bening hash for parsing errors" do
    benign = AkamaiCCU::Response.new("{[]}")
    benign.to_s.must_equal "status=400; detail=743: unexpected token at '{[]}'"
  end
end
