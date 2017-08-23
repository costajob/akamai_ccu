require "logger"
require "time"

module AkamaiCCU
  class Response
    BAD_STATUS = 400

    attr_reader :body, :title, :status, :detail, :support_id, :purge_id, :decribed_by, :completion_at

    def initialize(body: {}, time: Time.now, logger: Logger.new(nil))
      @logger = logger
      @body = parse(body)
      @title = @body["title"]
      @status = @body.fetch("httpStatus") { @body.fetch("status", BAD_STATUS) }
      @detail = @body["detail"]
      @support_id = @body.fetch("supportId") { @body["requestId"] }
      @purge_id = @body["purgeId"]
      @described_by = @body.fetch("describedBy") { @body["type"] }
      @estimated_secs = @body["estimatedSeconds"]
      @completion_at = time + @estimated_secs.to_i if @estimated_secs
    end

    def successful?
      (@status.to_i / 100) == 2
    end

    def to_s
      %W[status=#{@status}].tap do |a|
        a << "title=#{@title}" if @title
        a << "detail=#{@detail}" if @detail
        a << "support_id=#{@support_id}" if @support_id
        a << "purge_id=#{@purge_id}" if @purge_id
        a << "described_by=#{@described_by}" if @described_by
        a << "copletion_at=#{@completion_at}" if @completion_at
      end.join("; ")
    end

    private def parse(body)
      return body if body.is_a? Hash
      JSON.parse(body)
    rescue JSON::ParserError => e
      @logger.error { "reponse parse error: #{e.message}" }
    end
  end
end
