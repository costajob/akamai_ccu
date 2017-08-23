require "ostruct"

module Stubs
  extend self

  Secret = Struct.new(:client_secret, :host, :access_token, :client_token, :max_body, :signed_key, :auth_header) do
    def touch; Time.now; end

    def self.by_file(name); name; end

    def self.format_utc(time)
      AkamaiCCU::Secret.format_utc(time)
    end

    def self.sign(data)
      AkamaiCCU::Secret.sign(data)
    end

    def self.sign_HMAC(key, data)
      AkamaiCCU::Secret.sign_HMAC(key, data)
    end
  end

  Response = Struct.new(:body) do
    def to_s
      body.reduce([]) do |acc, (k,v)|
        acc << "#{k}=#{v}"
      end.join(";")
    end
  end

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

  Endpoint = Struct.new(:network, :action, :mode) do
    def path
      "ccu/v3/#{action}/#{mode}/#{network}"
    end
  end

  class Wrapper < OpenStruct
    class << self
      attr_reader :secret

      def setup(secret, client, logger)
        @secret = secret
        @client = client
        @logger = logger
      end
    end

    def call(objects)
      [].tap do |a|
        a << "secret=#{File.basename(self.class.secret)}"
        a << "endpoint=#{endpoint.path}"
        a << "headers=#{headers.join(",")}" unless headers.empty?
        a << "objects=#{objects.join(",")}"
      end.join(";")
    end
  end

  class HTTP
    attr_accessor :host, :port, :verify_mode, :use_ssl

    def initialize(host, port)
      @host, @port = host, port
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
      request = Stubs.post
      yield(request)
      Response.new(uri: URI.join(@host, path), request: request)
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

  def error_body
    {"title"=>"unauthorized cpcode", "supportId"=>"17PY1498401498349113-269829312", "httpStatus"=>403, "detail"=>"12345", "describedBy"=>"https://api.ccu.akamai.com/ccu/v2/errors/unauthorized-cpcode"}
  end

  def ack_body
    {"estimatedSeconds"=>5, "purgeId"=>"44ac266e-59b5-11e7-84ca-75d9dd540c3b", "supportId"=>"17PY1498402073417329-261436608", "httpStatus"=>201, "detail"=>"Request accepted"}
  end

  def txt_path
    File.expand_path("../tokens.txt", __FILE__)
  end

  def edgerc_path
    File.expand_path("../.edgerc", __FILE__)
  end

  def strip_log(s)
    s.strip.split("  ").last
  end

  def urls
    %w[https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/index.html https://akaa-baseurl-xxx-xxx.luna.akamaiapis.net/main.js]
  end

  def cpcodes
    %w[12345 98765]
  end

  def bulk_urls
    Tempfile.new(%w[bulk_urls .txt]).tap do |bulk|
      urls.each { |url| bulk.puts(url) }
      bulk.rewind
    end
  end

  def bulk_codes
    Tempfile.new(%w[bulk_codes .txt]).tap do |bulk|
      cpcodes.each { |code| bulk.puts(code) }
      bulk.rewind
    end
  end

  def bulk_mixed
    Tempfile.new(%w[bulk_mixed .txt]).tap do |bulk|
      cpcodes.each { |code| bulk.puts(code) }
      urls.each { |url| bulk.puts(url) }
      bulk.rewind
    end
  end

  def bulk_invalid
    Tempfile.new(%w[bulk_invalid .txt]).tap do |bulk|
      %w[index.html main.js stylesheets/homepage.css].each { |entry| bulk.puts(entry) }
      bulk.rewind
    end
  end
end
