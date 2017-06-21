require "time"

module AkamaiCCU
  class Response
    BAD_STATUS = 400

    def self.factory(body)
      response = new(body)
      case response
      when ->(res) { res.successful? }
        Ack.new(body)
      else
        Error.new(body)
      end
    end

    attr_reader :body, :status, :detail

    def initialize(body = {})
      @body = parse(body)
      @status = @body.fetch("httpStatus") { @body.fetch("status", BAD_STATUS) }
      @detail = @body["detail"]
    end

    def successful?
      (@status.to_i / 100) == 2
    end

    private def parse(body)
      return body if body.is_a? Hash
      JSON.parse(body)
    end
  end

  class Error < Response
    attr_reader :type, :title, :request_id, :instance, :method, :server_ip, :client_ip

    def initialize(body)
      super(body)
      @type = @body["type"]
      @title = @body["title"]
      @request_id = @body["requestId"]
      @instance = @body["instance"]
      @method = @body["method"]
      @serverIp = @body["serverIp"]
      @clientIp = @body["clientIp"]
      @requested_at = @body["requestTime"]
    end

    def requested_at
      return nil unless @requested_at
      Time.parse(@requested_at)
    end

    def to_s
      %W[status=#{@status}].tap do |a|
        a << "title=#{@title}" if @title
        a << "detail=#{@detail}" if @detail
        a << "request_id=#{@request_id}" if @request_id
        a << "method=#{@method}" if @method
        a << "requested_at=#{@requested_at}" if @requested_at
      end.join("; ")
    end
  end

  class Ack < Response
    attr_reader :purge_id, :estimated_secs, :support_id, :completion_at

    def initialize(body, time = Time.now)
      super(body)
      @purge_id = @body["purgeId"]
      @estimated_secs = @body["estimatedSeconds"]
      @support_id = @body["supportId"]
      @completion_at = time + @estimated_secs.to_i
    end

    def to_s
      %W[status=#{@status}].tap do |a|
        a << "detail=#{@detail}" if @detail
        a << "purge_id=#{@purge_id}" if @purge_id
        a << "support_id=#{@support_id}" if @support_id
        a << "copletion_at=#{AkamaiCCU.format_utc(@completion_at)}" if @completion_at
      end.join("; ")
    end
  end
end
