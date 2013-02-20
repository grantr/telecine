require 'telecine/transport'

module Telecine
  class LocalTransport
    include Transport
    include Celluloid::Notifications

    attr_accessor :channel

    def channel
      @channel ||= "telecine.transport.local.#{Celluloid::UUID.generate}"
    end

    #TODO this should be a uri
    def address
      channel
    end

    def write(message)
      publish(address, message)
    end
  end
end
