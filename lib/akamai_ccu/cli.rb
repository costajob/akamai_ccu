require "logger"
require "optparse"
require "akamai_ccu/wrapper"

module AkamaiCCU
  class CLI
    attr_reader :network, :action

    def initialize(args:, action:, io: STDOUT, wrapper_klass: Wrapper, secret_klass: Secret, endpoint_klass: Endpoint)
      @args = args
      @action = action
      @io = io
      @logger = Logger.new(io)
      @wrapper_klass = wrapper_klass
      @secret_klass = secret_klass
      @endpoint_klass = endpoint_klass
      @network = Endpoint::Network::STAGING
    end

    def call
      parser.parse!(@args)
      return @logger.warn("specify contents to purge either by cp codes or by urls") unless @objects
      return @logger.warn("specify path to the secret file either by edgerc or by txt") unless @secret
      return @logger.warn("specified secret file does not exist") unless File.exist?(@secret)
      wrapper = @wrapper_klass.new(secret: secret, endpoint: endpoint, headers: Array(@headers))
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
      File.readlines(file).map(&:strip).reject(&:empty?).map do |entry|
        entry = entry.to_i unless entry.start_with?("http")
        entry
      end
    end

    private def parser
      OptionParser.new do |opts|
        opts.banner = %Q{Usage: #{@action} --edgerc=./.edgerc --production --cp="12345, 98765"}

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
