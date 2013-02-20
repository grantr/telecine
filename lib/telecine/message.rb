require 'telecine/addresses'

module Telecine
  class InvalidMessageError < StandardError; end

  # What is needed from the Message?
  # 
  # transport:
  #   - a destination address with node and mailbox ids and an array of strings
  #
  # mailbox proxy:
  #   - a payload and a sender mailbox

  class Message
    attr_accessor :id, :headers, :payload, :body

    attr_accessor :sender, :destination
    attr_accessor :env

    def headers
      @headers = []
    end

    def id
      @id ||= Celluloid::UUID.generate
    end

    def env
      @env ||= {}
    end
  end
end
