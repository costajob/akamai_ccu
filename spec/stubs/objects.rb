module Stubs
  extend self

  Secret = Struct.new(:client_secret, :host, :access_token, :client_token, :max_body, :signed_key, :auth_header) do
    def touch; Time.now; end
  end

  Response = Struct.new(:body)

  Request = Struct.new(:headers, :body, :body_permitted, :method, :path) do
    def request_body_permitted?
      body_permitted
    end

    def key?(name)
      headers.has_key?(name)
    end

    def [](name)
      headers[name]
    end

    def []=(name, val)
      headers[name] = val
    end

    def fetch(name, &b)
      headers.fetch(name, &b)
    end

    def to_s
      "method=#{method};path=#{path};headers=#{headers.keys.join(",")};body=#{body}"
    end
  end

  class HTTP
    attr_accessor :host, :port, :verify_mode, :use_ssl

    def initialize(host, port)
      @host, @port = host, port
      @verify_mode, @use_ssl = 0, false
    end

    def request(payload)
      Response.new(payload.inspect) 
    end

    class Get
      attr_accessor :uri, :initheader

      def initialize(uri, initheader)
        @uri, @initheader = uri, initheader
      end

      def inspect
        "method=#{self.class};uri=#{uri};initheader=#{initheader.inspect}"
      end
    end

    class Post < Get
      attr_accessor :body

      def inspect
        "method=#{self.class};uri=#{uri};initheader=#{initheader.inspect};body=#{body.inspect}"
      end
    end
  end

  class Client
    def initialize(host:)
      @host = "https://#{host}"
    end

    def call(path:)
      request = yield(Stubs.post)
      "uri=#{URI.join(@host, path)};request=#{request}"
    end
  end

  class Signer
    def initialize(request, secret, headers = [])
      @request = request
      @secret = secret
      @headers = headers
    end

    def call!
      @request.tap do |req|
        req["Authorization"] = "#{@request["Authorization"]}"
      end
    end
  end

  def headers
    %w[accept user-agent]
  end

  def post
    Request.new({"accept-encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept"=>"*/*", "user-agent"=> "Ruby"}, {"objects"=>["http://bc.akamaiapibootcamp.com/index.html"]}.to_json, true, "POST", "https://#{Stubs.host}")
  end

  def get
    post.tap do |req|
      req.body_permitted = false
      req.method = "GET"
    end
  end

  def no_body
    post.tap do |req|
      req.body = nil
    end
  end

  def host
    "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/"
  end

  def secret
    Secret.new("xxx=", host, "akab-access-token-xxx-xxx", "akab-client-token-xxx-xxx", 2048, "tbZ+hvr+iv4cmC1+bi8sHCjPw6gqWmsfFYHa+Et1Wro=", "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;")
  end

  def short_secret
    secret.tap do |s|
      s.max_body = 10
    end
  end
end
