require "forwardable"
require "net/http"
require "json"
require "akamai_ccu/request"

module AkamaiCCU
  class Client
    extend Forwardable

    def_delegators :@secret, :host
    
    attr_reader :net_klass

    def initialize(secret:, net_klass: Net::HTTP)
      @secret = secret
      @net_klass = net_klass
    end

    def call(path:, method: GET, initheader: nil)
      request(path, method, initheader)
      yield @request if block_given?
      http.request(@request)
    end

    private def base_uri
      "https://#{host}"
    end

    private def http
      @http ||= @net_klass.new(base_uri, SSL_PORT)
    end

    private def request(path, klass = GET, initheader = nil)
      uri = URI.join(base_uri, path)
      @request ||= @net_klass.const_get(klass).new(uri.to_s, initheader)
    end
  end
end
