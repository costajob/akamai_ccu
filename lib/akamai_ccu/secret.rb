require "uri"
require "securerandom"

module AkamaiCCU
  class Secret
    DIGEST = "EG1-HMAC-SHA256"
    ENTRY_REGEX = /(.+?)\s?=\s?(.+)/ 
    BODY_SIZE = 131072

    class FileContentError < ArgumentError; end

    class << self
      private def factory(opts, time)
        new(client_secret: opts.fetch("client_secret"), host: opts.fetch("host"), access_token: opts.fetch("access_token"), client_token: opts.fetch("client_token"), max_body: opts.fetch("max-body", BODY_SIZE), time: time)
      end

      def by_file(name = "~/.edgerc", time = Time.now)
        path = File.expand_path(name)
        return unless File.exist?(path)
        data = File.readlines(path).reduce([]) do |acc, entry|
          m = entry.match(ENTRY_REGEX)
          acc << [m[1], m[2]] if m
          acc
        end
        factory(Hash[data], time)
      rescue KeyError => e
        raise FileContentError, "bad file content, #{e.message}", e.backtrace
      end
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
      @timestamp = AkamaiCCU.format_utc(time) 
    end

    def touch
      @nonce = SecureRandom.uuid
      @timestamp = AkamaiCCU.format_utc(Time.now)
      self
    end

    def signed_key
      AkamaiCCU.sign_HMAC(key: @client_secret, data: @timestamp)
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
