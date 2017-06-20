require "helper"

describe AkamaiCCU::Response do
  it "must detect succesful response" do
    response = AkamaiCCU::Response.new("status"=>201)
    response.successful?.must_equal true
  end

  it "must factory an error instance" do
    response = AkamaiCCU::Response.by_json(Stubs.error_body.to_json)
    response.must_be_instance_of AkamaiCCU::Error
    response.request_id.must_equal "20e31be4"
  end

  it "must factory an ack instance" do
    response = AkamaiCCU::Response.by_json(Stubs.ack_body.to_json)
    response.must_be_instance_of AkamaiCCU::Ack
    response.purge_id.must_equal "e535071c-26b2-11e7-94d7-276f2f54d938"
  end

  describe AkamaiCCU::Error do
    let(:error) { AkamaiCCU::Error.new(Stubs.error_body) }

    it "must be represented as a string" do
      error.to_s.must_equal "status=400; title=Bad request; detail=Invalid timestamp; request_id=20e31be4; method=POST; requested_at=2017-06-20T12:19:11Z"
    end

    it "must express requested_at as time" do
      error.requested_at.must_equal Time.parse("2017-06-20T12:19:11Z")
    end
  end

  describe AkamaiCCU::Ack do
    let(:ack) { AkamaiCCU::Ack.new(Stubs.ack_body, Time.new(2017,6,20,12,19,11, "+01:00")) }

    it "must be represented as a string" do
      ack.to_s.must_equal "status=201; detail=Request accepted; purge_id=e535071c-26b2-11e7-94d7-276f2f54d938; support_id=17PY1492793544958045-219026624; copletion_at=20170620T11:19:16+0000"
    end

    it "must express completion at as time" do
      ack.completion_at.must_equal Time.parse("2017-06-20 12:19:16 +0100")
    end
  end
end
