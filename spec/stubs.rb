module Stubs
  extend self

  Secret = Struct.new(:client_secret, :host, :access_token, :client_token, :max_body, :signed_key)
  Raw = Struct.new(:keys, :body, :body_permitted, :method, :path) do
    def request_body_permitted?
      body_permitted
    end

    def key?(name)
      keys.has_key?(name)
    end

    def [](name)
      keys[name]
    end
  end

  def headers
    %w[accept user-agent]
  end

  def raw
    Raw.new({"accept-encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept"=>"*/*", "user-agent"=> "Ruby"}, "example body of the request", true, "POST", "https://www.ruby-lang.org")
  end

  def secret
    Secret.new("xxx=", "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", "akab-access-token-xxx-xxx", "akab-client-token-xxx-xxx", 2048, "tbZ+hvr+iv4cmC1+bi8sHCjPw6gqWmsfFYHa+Et1Wro=")
  end
end
