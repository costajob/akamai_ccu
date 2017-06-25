require "net/http"
require "openssl"

module AkamaiCCU
  class Client
    GET = :Get
    POST = :Post
    SSL = "https"
    JSON_HEADER = { "Content-Type" => "application/json" }

    attr_reader :net_klass, :host

    def initialize(host:, net_klass: Net::HTTP)
      @host = host
      @net_klass = net_klass
    end

    def call(path:, method: POST, initheader: JSON_HEADER)
      request(path, method, initheader)
      yield @request if block_given?
      Thread.new { http.request(@request) }.value
    end

    private def base_uri
      @base_uri ||= URI("#{SSL}://#{host}")
    end

    private def http
      @http ||= @net_klass.new(base_uri.host, base_uri.port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
    end

    private def request(path, klass = GET, initheader = nil)
      @request ||= @net_klass.const_get(klass).new(base_uri.merge(path).to_s, initheader)
    end
  end
end
