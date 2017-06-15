module Stubs
  extend self

  Secret = Struct.new(:client_secret, :host, :access_token, :client_token, :max_body, :signed_key, :auth_header)

  Response = Struct.new(:body)

  class HTTP
    attr_accessor :host, :port

    def initialize(host, port)
      @host, @port = host, port
    end

    def request(payload)
      Response.new("response: #{payload.inspect}") 
    end

    class Get
      attr_accessor :uri, :initheader

      def initialize(uri, initheader)
        @uri, @initheader = uri, initheader
      end

      def inspect
        "#{self.class}: uri=#{uri}; initheader=#{initheader.inspect}"
      end
    end

    class Post < Get
      def body
        @body
      end

      def body=(body)
        @body = body
      end

      def inspect
        "#{self.class}: uri=#{uri}; initheader=#{initheader.inspect}; body=#{body.inspect}"
      end
    end
  end

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

    def []=(name, val)
      keys[name] = val
    end

    def fetch(name, &b)
      keys.fetch(name, &b)
    end
  end

  def headers
    %w[accept user-agent]
  end

  def post
    Raw.new({"accept-encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept"=>"*/*", "user-agent"=> "Ruby"}, {"objects"=>["/f/4/6848/4h/www.foofoofoo.com/index.php", "/f/4/6848/4h/www.oofoofoof.com/index2.php", "http://www.example.com/graphics/picture.gif", "http://www.example.com/documents/brochure.pdf"]}.to_json, true, "POST", "https://www.ruby-lang.org")
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

  def secret
    Secret.new("xxx=", "akaa-baseurl-xxx-xxx.luna.akamaiapis.net/", "akab-access-token-xxx-xxx", "akab-client-token-xxx-xxx", 2048, "tbZ+hvr+iv4cmC1+bi8sHCjPw6gqWmsfFYHa+Et1Wro=", "EG1-HMAC-SHA256 client_token=akab-client-token-xxx-xxx;access_token=akab-access-token-xxx-xxx;timestamp=20171029T14:34:12+0000;nonce=70dc53b8-99a5-4a00-9f04-658eafa437af;")
  end

  def short_secret
    secret.tap do |s|
      s.max_body = 10
    end
  end
end
