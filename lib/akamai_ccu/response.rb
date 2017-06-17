module AkamaiCCU
  class Response
    def initialize(body)
      @id = body.fetch("supportId")
      @title = body.fetch("title")
      @status = body.fetch("httpStatus", 200)
      @details = body.fetch("detail")
      @url = body.fetch("describedBy")
    end
  end
end
