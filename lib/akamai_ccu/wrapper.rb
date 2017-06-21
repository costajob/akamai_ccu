require "akamai_ccu/client"
require "akamai_ccu/endpoint"
require "akamai_ccu/signer"
require "akamai_ccu/response"

module AkamaiCCU
  class Wrapper
    class << self
      Endpoint::Network.constants.each do |network|
        Endpoint::Action.constants.each do |action|
          Endpoint::Mode.constants.each do |mode|
            endpoint = Endpoint.by_constants(network, action, mode)
            define_method(endpoint.to_s) do |objects = [], secret = nil, headers = [], &block|
              wrapper = new(secret: secret, endpoint: endpoint, headers: headers)
              block.call(wrapper) if block
              wrapper.call(objects)
            end
          end
        end
      end
    end

    attr_accessor :endpoint, :client_klass, :signer_klass, :response_klass

    def initialize(secret:, endpoint:, headers: [],
                   client_klass: Client, signer_klass: Signer, response_klass: Response)
      @secret = secret
      @endpoint = endpoint
      @client_klass = client_klass
      @signer_klass = signer_klass
      @response_klass = response_klass
      @headers = headers
    end

    def call(objects = [])
      return if objects.empty?
      res = client.call(path: @endpoint.path) do |request|
        request.body = { objects: objects }.to_json
        @secret.touch
        @signer_klass.new(request, @secret, @headers).call!
      end
      response_klass.factory(res.body)
    end

    private def client
      @client ||= @client_klass.new(host: @secret.host)
    end
  end
end
