$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "base64"
require "openssl"
require "akamai_ccu/version"
require "akamai_ccu/client"
require "akamai_ccu/secret"
require "akamai_ccu/request"

module AkamaiCCU
  extend self

  GET = :Get
  POST = :Post
  JSON_CONTENT = { "Content-Type" => "application/json" }

  def format_utc(time)
    time.utc.strftime("%Y%m%dT%H:%M:%S+0000")
  end

  def sign(data)
    digest = OpenSSL::Digest::SHA256.new.digest(data)
    Base64.encode64(digest).strip
  end

  def sign_HMAC(key:, data:)
    digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, data, key)
    Base64.encode64(digest).strip
  end
end
