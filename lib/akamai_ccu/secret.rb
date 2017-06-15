require "uri"
require "securerandom"

module AkamaiCCU
  class Secret
    DIGEST = "EG1-HMAC-SHA256"

    attr_reader :host, :max_body

    def initialize(client_secret:, host:, access_token:, client_token:, max_body: 2048, nonce: SecureRandom.uuid, time: Time.now)
      @client_secret = client_secret
      @host = URI(host)
      @access_token = access_token
      @client_token = client_token
      @max_body = max_body
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
