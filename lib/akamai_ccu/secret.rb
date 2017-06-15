require "uri"
require "securerandom"

module AkamaiCCU
  class Secret
    DIGEST = "EG1-HMAC-SHA256"
    EQUALITY_REGEX = /\s?+=\s?/

    class << self
      private def factory(opts)
        new(client_secret: opts.fetch("client_secret"), host: opts.fetch("host"), access_token: opts.fetch("access_token"), client_token: opts.fetch("client_token"), max_body: opts.fetch("max-body", 2048))
      end

      def by_file(name)
        return unless File.exist?(name)
        data = File.readlines(name).map(&:strip).reject(&:empty?).map do |entry| 
          entry.split(EQUALITY_REGEX)
        end
        factory(Hash[data])
      end

      def by_edgerc(name = File.join($HOME, ".edgerc"))
        return unless File.exist?(name)
        data = File.readlines(name).map(&:strip)
        data.shift
        data.map! { |entry| entry.split(EQUALITY_REGEX) }
        factory(Hash[data])
      end
    end

    attr_reader :host, :max_body

    def initialize(client_secret:, host:, access_token:, client_token:, max_body: 2048, nonce: SecureRandom.uuid, time: Time.now)
      @client_secret = client_secret
      @host = URI(host)
      @access_token = access_token
      @client_token = client_token
      @max_body = max_body.to_i
      @nonce = nonce
      @timestamp = AkamaiCCU.format_utc(time) 
    end

    def signed_key
      AkamaiCCU.sign_HMAC(key: @client_secret, data: @timestamp)
    end

    def auth_header
      DIGEST.tap do |header|
        header << " "
        header << "client_token=#{@client_token};"
        header << "access_token=#{@access_token};"
        header << "timestamp=#{@timestamp};"
        header << "nonce=#{@nonce};"
      end
    end
  end
end
