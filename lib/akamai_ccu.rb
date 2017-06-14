$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "base64"
require "openssl"
require "akamai_ccu/version"
require "akamai_ccu/client"
require "akamai_ccu/secret"
require "akamai_ccu/request"

module AkamaiCCU
  extend self

  def format_utc(t = Time.now)
    t.utc.strftime("%Y%m%dT%H:%M:%S+0000")
  end

  def sign(data = AkamaiCCU.format_utc)
    digest = OpenSSL::Digest::SHA256.new.digest(data)
    Base64.encode64(digest).strip
  end

  def sign_HMAC(key:, data: AkamaiCCU.format_utc)
    digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, key, data)
    Base64.encode64(digest).strip
  end
end
