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

  class Envelope
    attr_accessor :id, :contents
    attr_accessor :sender, :destination

    def id
      @id ||= Celluloid::UUID.generate
    end
  end
end
