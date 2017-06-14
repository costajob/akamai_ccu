require "forwardable"

module AkamaiCCU
  class Request
    extend Forwardable

    POST = "POST"
    TAB = "\t"

    def_delegators :@raw, :body, :request_body_permitted?, :path, :method
    def_delegators :@secret, :max_body

    def initialize(raw:, secret:, headers: [])
      @raw = raw
      @secret = secret
      @headers = headers
      @url = URI(path)
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
      truncated = body[0..max_body-1]
      AkamaiCCU.sign(truncated)
    end

    private def signed_header
    end

    private def signature_data
      [].tap do |data|
        data << method
        data << @url.scheme
        data << @raw.fetch("host") { @url.host }
        data << @url.request_uri
        data << canonical_headers.join(TAB)
        data << signed_body
        data << signed_header
      end
    end
  end
end
