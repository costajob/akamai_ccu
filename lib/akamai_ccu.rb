$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "base64"
require "json"
require "openssl"
require "akamai_ccu/version"
require "akamai_ccu/client"
require "akamai_ccu/signer"
require "akamai_ccu/invalidator"

module AkamaiCCU
  extend self

  GET = :Get
  POST = :Post
  SSL = "https"
  JSON_HEADER = { "Content-Type" => "application/json" }

  def format_utc(time)
    time.utc.strftime("%Y%m%dT%H:%M:%S+0000")
  end

  def sign(data)
    digest = OpenSSL::Digest::SHA256.new.digest(data)
    Base64.encode64(digest).strip
  end

  def sign_HMAC(key:, data:)
    digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, key, data)
    Base64.encode64(digest).strip
  end
end
