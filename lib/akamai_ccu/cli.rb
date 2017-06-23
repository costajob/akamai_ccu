require "logger"
require "optparse"
require "akamai_ccu/wrapper"

module AkamaiCCU
  class CLI
    SCHEME = "http"
    LOG_LEVEL = Logger.const_get(ENV.fetch("LOG_LEVEL", "INFO"))

    attr_reader :network, :action

    def initialize(args:, action:, io: STDOUT, wrapper_klass: Wrapper, secret_klass: Secret, endpoint_klass: Endpoint)
      @args = args
      @action = action
      @io = io
      @logger = Logger.new(io)
      @logger.level = LOG_LEVEL
      @wrapper_klass = wrapper_klass
      @secret_klass = secret_klass
      @endpoint_klass = endpoint_klass
      @network = Endpoint::Network::STAGING
    end

    def call
      parser.parse!(@args)
      return @logger.warn("specify contents to purge by bulk, CP codes or urls") if Array(@objects).empty?
      return @logger.warn("specify path to the secret file either by edgerc or by txt") unless @secret
      return @logger.warn("specified secret file does not exist") unless File.exist?(@secret)
      @wrapper_klass.setup(secret, Client, @logger)
      wrapper = @wrapper_klass.new(endpoint: endpoint, headers: Array(@headers))
      @logger.info wrapper.call(@objects).to_s
    end

    private def secret
      return @secret_klass.by_txt(@secret) if File.extname(@secret) == ".txt"
      @secret_klass.by_edgerc(@secret)
    end

    private def endpoint
      @endpoint_klass.new(network, action, mode) 
    end

    private def mode
      return Endpoint::Mode::CPCODE if @objects.all? { |o| o.is_a?(Integer) } 
      Endpoint::Mode::URL
    end

    private def bulk_objects(file)
      return unless File.exist?(file)
      data = File.readlines(file).map(&:strip).reject(&:empty?)
      return data if data.all? { |entry| entry.downcase.start_with?(SCHEME) }
      data.map(&:to_i).reject(&:zero?)
    end

    private def parser
      OptionParser.new do |opts|
        opts.banner = %Q{Usage: ccu_#{@action} --edgerc=./.edgerc --production --cp="12345, 98765"}

        opts.on("-eEDGERC", "--edgerc=EDGERC", "Load secret by .edgerc file") do |secret|
          @secret = File.expand_path(secret)
        end

        opts.on("-tTXT", "--txt=TXT", "Load secret by TXT file") do |secret|
          @secret = File.expand_path(secret)
        end

        opts.on("-cCP", "--cp=CP", "Specify contents by provider (CP) codes") do |objects|
          @objects = objects.split(",").map(&:strip).map(&:to_i)
        end

        opts.on("-uURL", "--url=URL", "Specify contents by URLs") do |objects|
          @objects = objects.split(",").map(&:strip)
        end

        opts.on("-bBULK", "--bulk=BULK", "Specify bulk contents in a file") do |bulk|
          @objects = bulk_objects(File.expand_path(bulk))
        end

        opts.on("--headers=HEADERS", "Specify HTTP headers to sign") do |headers|
          @headers = headers.split(",").map(&:strip)
        end

        opts.on("-p", "--production", "Purge on production network") do |prod|
          @network = Endpoint::Network::PRODUCTION
        end

        opts.on("-h", "--help", "Prints this help") do
          @io.puts opts
          exit
        end
      end
    end
  end
end
