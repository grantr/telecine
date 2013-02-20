require 'telecine/transport'

module Telecine
  class LocalTransport
    include Transport
    include Celluloid::Notifications

    attr_accessor :channel

    def initialize
      subscribe(channel, :handle_message)
      start
    end

    def channel
      @channel ||= "telecine.transport.local.#{Celluloid::UUID.generate}"
    end

    #TODO this should be a uri
    def address
      channel
    end

    def handle_message(topic, message)
      dispatch(message)
    end

    def write(message)
      puts "publishing #{message} to #{message.destination.node_id}"
      publish(message.destination.node_id, message)
    end
  end
end
