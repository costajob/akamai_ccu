module AkamaiCCU
  class Endpoint
    BASE_PATH = "/ccu/v3"
    SHEBANG = "!"

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

    def self.by_constants(network_const, action_const, mode_const)
      network = Network.const_get(network_const)
      action = Action.const_get(action_const)
      mode = Mode.const_get(mode_const)
      new(network, action, mode)
    end

    def self.by_name(name)
      network = name.delete!(SHEBANG) ? Network::PRODUCTION : Network::STAGING
      tokens = name.split("_")
      tokens.delete("by")
      action, mode = tokens
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
      SHEBANG if production?
    end
  end
end
