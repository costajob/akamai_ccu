require "forwardable"
require "akamai_ccu/signer"
require "akamai_ccu/client"

module AkamaiCCU
  class Invalidator
    extend Forwardable

    PATH = "/ccu/v3/invalidate/url"

    def_delegators :@secret, :host

    def initialize(hostname:, secret:, client_klass: Client, signer_klass: Signer)
      @hostname = hostname
      @secret = secret
      @client_klass = client_klass
      @signer_klass = signer_klass
    end

    def call(objects: [])
      client.call(path: PATH) do |request|
        request.body = { hostname: @hostname, objects: objects }.to_json
        @signer_klass.new(request, @secret).call!
      end
    end

    private def client
      @client ||= @client_klass.new(host: host)
    end
  end
end
