require "forwardable"
require "uri"
require "akamai_ccu/secret"

module AkamaiCCU
  class Request
    extend Forwardable

    POST = "POST"
    TAB = "\t"
    HEADER_NAME = "signature"
    HEADER_KEY = "Authorization"

    def_delegators :@raw, :body, :request_body_permitted?, :path, :method
    def_delegators :@secret, :max_body, :auth_header, :signed_key

    attr_reader :raw

    def initialize(raw:, secret:, headers: [])
      @raw = raw
      @secret = secret
      @headers = headers
      @url = URI(path)
    end

    def decorate!
      @raw[HEADER_KEY] = signed_headers
    end

    private def canonical_headers
      @headers.map do |header|
        next unless @raw.key?(header)
        value = @raw[header].strip.gsub(/\s+/, " ")
        "#{header.downcase}:#{value}"
      end.compact
    end

    private def body?
      body && request_body_permitted?
    end

    private def signed_body
      return "" unless body?
      truncated = body[0...max_body]
      AkamaiCCU.sign(truncated)
    end

    private def signature_data
      @signature_data ||= [].tap do |data|
        data << method
        data << @url.scheme
        data << @raw.fetch("host") { @url.host }
        data << @url.request_uri
        data << canonical_headers.join(TAB)
        data << signed_body
        data << auth_header
      end
    end

    private def signature
      AkamaiCCU.sign_HMAC(key: signed_key, data: signature_data.join(TAB))
    end

    def signed_header
      "#{HEADER_NAME}=#{signature}"
    end

    private def signed_headers
      @signed_headers ||= auth_header << signed_header
    end
  end
end
