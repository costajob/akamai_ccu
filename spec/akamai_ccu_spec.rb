require "helper"

describe AkamaiCCU do
  it "must generate timestamp as a string" do
    AkamaiCCU.format_utc(Time.new(2017,1,1,15,30,20, "+01:00")).must_equal "20170101T14:30:20+0000"
  end

  it "must sign by digest" do
    AkamaiCCU.sign("my_data").must_equal "4fQDOPZLl0qzjYcR1R2OhIYRqoyp+NTf2tCmHDCneqw="
  end

  it "must sign by HMAC digest" do
    AkamaiCCU.sign_HMAC(key: "my_key", data: "my_data").must_equal "cgT5WPnSQ+4Ucq2Sd0iReNUllb0URgEkCOxqO8tCohI="
  end
end
