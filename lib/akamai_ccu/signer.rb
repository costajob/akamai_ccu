require "forwardable"
require "akamai_ccu/secret"

module AkamaiCCU
  class Signer
    extend Forwardable

    POST = "POST"
    TAB = "\t"
    HEADER_NAME = "signature"
    HEADER_KEY = "Authorization"

    def_delegators :@request, :body, :request_body_permitted?, :path, :method
    def_delegators :@secret, :max_body, :auth_header, :signed_key

    attr_reader :request

    def initialize(request, secret, headers = [])
      @request = request
      @secret = secret
      @headers = Array(headers)
      @url = URI(path)
    end

    def call!
      @request[HEADER_KEY] = signed_headers
    end

    private def canonical_headers
      @headers.map do |header|
        next unless @request.key?(header)
        value = @request[header].strip.gsub(/\s+/, " ")
        "#{header.downcase}:#{value}"
      end.compact
    end

    private def body?
      body && request_body_permitted?
    end

    private def signed_body
      return "" unless body?
      truncated = body[0...max_body]
      @secret.class.sign(truncated)
    end

    private def signature_data
      @signature_data ||= [].tap do |data|
        data << method
        data << @url.scheme
        data << @request.fetch("host") { @url.host }
        data << @url.request_uri
        data << canonical_headers.join(TAB)
        data << signed_body
        data << auth_header
      end
    end

    private def signature
      @secret.class.sign_HMAC(signed_key, signature_data.join(TAB))
    end

    def signed_header
      "#{HEADER_NAME}=#{signature}"
    end

    private def signed_headers
      @signed_headers ||= auth_header << signed_header
    end
  end
end
