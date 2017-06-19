require "forwardable"
require "akamai_ccu/signer"
require "akamai_ccu/client"

module AkamaiCCU
  class Wrapper
    extend Forwardable

    BASE_PATH = "/ccu/v3/invalidate"

    %w[staging production].each do |network|
      const_set(network.upcase, network)
    end

    %w[url cpcode].each do |action|
      const_set("#{action}_action".upcase, action)
    end

    def_delegators :@secret, :host

    def initialize(secret:, action: URL_ACTION, network: STAGING, client_klass: Client, signer_klass: Signer)
      @secret = secret
      @action = action
      @network = network
      @client_klass = client_klass
      @signer_klass = signer_klass
    end

    def call(objects = [])
      client.call(path: path) do |request|
        request.body = { objects: objects }.to_json
        @signer_klass.new(request, @secret).call!
      end
    end

    private def path
      @path = File.join(BASE_PATH, @action, @network)
    end

    private def client
      @client ||= @client_klass.new(host: host)
    end
  end
end
