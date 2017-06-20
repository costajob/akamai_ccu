require "akamai_ccu/signer"
require "akamai_ccu/client"

module AkamaiCCU
  class Wrapper
    class API
      BASE_PATH = "/ccu/v3"

      module Network
        %w[staging production].each do |network|
          const_set(network.upcase, network)
        end
      end

      module Action
        %w[invalidate delete].each do |action|
          const_set("#{action}".upcase, action)
        end
      end

      module Mode
        %w[url cpcode].each do |mode|
          const_set("#{mode}".upcase, mode)
        end
      end

      def self.default
        new(Network::STAGING, Action::INVALIDATE, Mode::URL)
      end

      def self.by_constants(network_const, action_const, mode_const)
        network = Network.const_get(network_const)
        action = Action.const_get(action_const)
        mode = Mode.const_get(mode_const)
        new(network, action, mode)
      end

      attr_reader :network, :action, :mode

      def initialize(network, action, mode)
        @network = network
        @action = action
        @mode = mode
      end

      def to_s
        "#{@action}_by_#{@mode}#{shebang}"
      end

      def path
        File.join(BASE_PATH, @action, @mode, @network)
      end

      private def production?
        @network == Network::PRODUCTION
      end

      private def shebang
        "!" if production?
      end
    end

    class << self
      API::Network.constants.each do |network|
        API::Action.constants.each do |action|
          API::Mode.constants.each do |mode|
            api = API.by_constants(network, action, mode)
            define_method(api.to_s) do |objects = [], secret = nil, headers = [], &block|
              wrapper = new(secret: secret, api: api, headers: headers)
              block.call(wrapper) if block
              wrapper.call(objects)
            end
          end
        end
      end
    end

    attr_accessor :secret, :client_klass, :signer_klass

    def initialize(secret: nil, api: API.default, client_klass: Client, signer_klass: Signer, headers: [])
      @secret = secret
      @api = api
      @client_klass = client_klass
      @signer_klass = signer_klass
      @headers = headers
    end

    def call(objects = [])
      return if objects.empty?
      client.call(path: @api.path) do |request|
        request.body = { objects: objects }.to_json
        @signer_klass.new(request, @secret, @headers).call!
      end
    end

    private def client
      @client ||= @client_klass.new(host: secret.host)
    end
  end
end
