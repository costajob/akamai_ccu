require "helper"

describe AkamaiCCU::Signer do
  let(:signer_post) { AkamaiCCU::Signer.new(Stubs.post, Stubs.secret, Stubs.headers) }
  let(:signer_get) { AkamaiCCU::Signer.new(Stubs.get, Stubs.secret, Stubs.headers) }
  let(:signer_no_headers) { AkamaiCCU::Signer.new(Stubs.post, Stubs.secret) }
  let(:signer_short) { AkamaiCCU::Signer.new(Stubs.post, Stubs.short_secret, Stubs.headers) }
  let(:signer_no_body) { AkamaiCCU::Signer.new(Stubs.no_body, Stubs.secret, Stubs.headers) }

  it "must skip signing for nil secret" do
    signer = AkamaiCCU::Signer.new(Stubs.post)
    signer.call!.must_be_nil
    signer.request.headers.wont_include "Authorization"
  end

  it "must sign the authorization key" do
    [signer_post, signer_get, signer_no_headers, signer_short, signer_no_body].each do |signer|
      signer.call!
      signer.request.headers.must_include "Authorization"
    end
  end

  it "must sign post request" do
    signer_post.call!.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=1oWo6QIedWD3fMMSfiggiLZBGxTA2gPkWftutahahno="
  end

  it "must sign get request" do
    signer_get.call!.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=ppud7GgMmJbkTXRk3YdbBh802v+SE7y8DlCbkj85m3o="
  end

  it "must sign no headers request" do
    signer_no_headers.call!.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=xGpNmKhEObI5+THX4o5SlxZ3bENw2McIswmSFJc6Ogg="
  end

  it "must sign truncated body request" do
    signer_short.call!.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=FIze6ZdxyTkMq1ZVTs/chC76VATKpeng5BRI2OoFwLs="
  end

  it "must sign no-body request" do
    signer_no_body.call!.must_equal "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;signature=CeW647DwUeiGEQC2kyw8VkX9JsCGQsYJWPOGSj6SBFs="
  end
end
