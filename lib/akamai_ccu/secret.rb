require "uri"
require "securerandom"

module AkamaiCCU
  class Secret
    DIGEST = "EG1-HMAC-SHA256"

    attr_reader :host, :max_body

    def initialize(client_secret:, host:, access_token:, client_token:, max_body: 2048, nonce: SecureRandom.uuid)
      @client_secret = client_secret
      @host = URI(host)
      @access_token = access_token
      @client_token = client_token
      @max_body = max_body
      @nonce = nonce
    end

    def signed_key
      AkamaiCCU.sign_HMAC(key: @client_secret)
    end

    def auth_header
      DIGEST.tap do |header|
        header << " "
        header << "client_token=#{@client_token};"
        header << "access_token=#{@access_token};"
        header << "timestamp=#{AkamaiCCU.format_utc};"
        header << "nonce=#{@nonce};"
      end
    end
  end
end
