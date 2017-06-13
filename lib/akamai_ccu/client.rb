require "json"
require "net/https"
require "uri"

module AkamaiCCU
  class Client
    BASE_URL = "https://api.ccu.akamai.com"

    def initialize(url: BASE_URL, user:, password:)
      @url = URI.parse(url)
      @user = user
      @password = password
    end

    private def authenticate
    end
  end
end
