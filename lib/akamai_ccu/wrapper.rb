require "forwardable"
require "akamai_ccu/signer"
require "akamai_ccu/client"

module AkamaiCCU
  class Wrapper
    extend Forwardable

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

    class << self
      Network.constants.each do |network|
        Action.constants.each do |action|
          Mode.constants.each do |mode|
            action_val = Action.const_get(action)
            mode_val = Mode.const_get(mode)
            shebang = "!" if network == :PRODUCTION
            name = "#{action_val}_by_#{mode_val}#{shebang}"
            define_method(name) do |secret, objects = [], headers = []|
              wrapper = new(secret: secret, action: action_val, mode: mode_val, network: network_val, headers: headers)
            wrapper.call(objects)
            end
          end
        end
      end
    end

    def_delegators :@secret, :host

    def initialize(secret:, action: Action::INVALIDATE, mode: Mode::URL, network: Network::STAGING, client_klass: Client, signer_klass: Signer, headers: [])
      @secret = secret
      @action = action
      @mode = mode
      @network = network
      @client_klass = client_klass
      @signer_klass = signer_klass
      @headers = headers
    end

    def call(objects = [])
      client.call(path: path) do |request|
        request.body = { objects: objects }.to_json
        @signer_klass.new(request, @secret, @headers).call!
      end
    end

    private def path
      @path = File.join(BASE_PATH, @action, @mode, @network)
    end

    private def client
      @client ||= @client_klass.new(host: host)
    end
  end
end
