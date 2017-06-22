require "akamai_ccu/client"
require "akamai_ccu/endpoint"
require "akamai_ccu/signer"
require "akamai_ccu/response"

module AkamaiCCU
  class Wrapper
    class << self
      attr_reader :secret, :client

      def setup(secret, client_klass = Client)
        @secret ||= secret
        @client ||= client_klass.new(host: @secret.host)
      end

      Endpoint::Network.constants.each do |network|
        Endpoint::Action.constants.each do |action|
          Endpoint::Mode.constants.each do |mode|
            endpoint = Endpoint.by_constants(network, action, mode)
            define_method(endpoint.to_s) do |objects, headers = [], &block|
              wrapper = new(endpoint: endpoint, headers: headers)
              block.call(wrapper) if block
              wrapper.call(objects)
            end
          end
        end
      end
    end

    attr_accessor :signer_klass, :response_klass

    def initialize(endpoint:, headers: [], signer_klass: Signer, response_klass: Response)
      @endpoint = endpoint
      @signer_klass = signer_klass
      @response_klass = response_klass
      @headers = headers
    end

    def call(objects)
      res = self.class.client.call(path: @endpoint.path) do |request|
        request.body = { objects: objects }.to_json
        @signer_klass.new(request, self.class.secret.touch, @headers).call!
      end
      response_klass.factory(res.body)
    end
  end
end
