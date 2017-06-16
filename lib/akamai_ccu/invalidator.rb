require "forwardable"
require "akamai_ccu/request"
require "akamai_ccu/client"

module AkamaiCCU
  class Invalidator
    extend Forwardable

    PATH = "/ccu/v3/invalidate/url"

    def_delegators :@secret, :host

    def initialize(secret:, client_klass: Client, req_klass: Request)
      @secret = secret
      @client_klass = client_klass
      @req_klass = req_klass
    end

    def call(host:, objects: [])
      client.call(path: PATH) do |request|
        request.body = { hostname: host, objects: objects }.to_json
        @req_klass.new(raw: request, secret: @secret).decorate!
      end
    end

    private def client
      @client ||= @client_klass.new(host: host)
    end
  end
end
