require "base64"
require "openssl"
require "securerandom"
require "uri"

module AkamaiCCU
  class Secret
    DIGEST = "EG1-HMAC-SHA256"
    ENTRY_REGEX = /(.+?)\s?=\s?(.+)/ 
    BODY_SIZE = 131072

    class FileContentError < ArgumentError; end

    def self.format_utc(time)
      time.utc.strftime("%Y%m%dT%H:%M:%S+0000")
    end

    def self.sign(data)
      digest = OpenSSL::Digest::SHA256.new.digest(data)
      Base64.encode64(digest).strip
    end

    def self.sign_HMAC(key, data)
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, key, data)
      Base64.encode64(digest).strip
    end

    def self.by_file(name = "~/.edgerc", time = Time.now)
      path = File.expand_path(name)
      return unless File.exist?(path)
      opts = File.readlines(path).reduce({}) do |acc, entry|
        _, k, v = Array(entry.match(ENTRY_REGEX))
        acc[k] = v if k && v
        acc
      end
      new(client_secret: opts.fetch("client_secret"), host: opts.fetch("host"), access_token: opts.fetch("access_token"), client_token: opts.fetch("client_token"), max_body: opts.fetch("max-body", BODY_SIZE), time: time)
    rescue KeyError => e
      raise FileContentError, "bad file content, #{e.message}", e.backtrace
    end

    attr_reader :host, :max_body, :nonce, :timestamp

    def initialize(client_secret:, host:, access_token:, client_token:, 
                   max_body: BODY_SIZE, nonce: SecureRandom.uuid, time: Time.now)
      @client_secret = client_secret
      @host = URI(host)
      @access_token = access_token
      @client_token = client_token
      @max_body = max_body.to_i
      @nonce = nonce
      @timestamp = self.class.format_utc(time) 
    end

    def touch
      @nonce = SecureRandom.uuid
      @timestamp = self.class.format_utc(Time.now)
      self
    end

    def signed_key
      self.class.sign_HMAC(@client_secret, @timestamp)
    end

    def auth_header
      DIGEST.dup.tap do |header|
        header << " "
        header << "client_token=#{@client_token};"
        header << "access_token=#{@access_token};"
        header << "timestamp=#{@timestamp};"
        header << "nonce=#{@nonce};"
      end
    end
  end
end
