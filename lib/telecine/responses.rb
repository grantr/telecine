module Telecine
  # Responses to calls
  class Response
    attr_reader :request_id, :value

    def initialize(request_id, value)
      @request_id, @value = request_id, value
    end
  end

  # Request successful
  class SuccessResponse < Response; end

  # Request failed
  class ErrorResponse < Response; end
end
