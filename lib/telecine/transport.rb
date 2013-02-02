require 'telecine/message'

module Telecine
  module Transport
    def self.included(base)
      base.class_eval do
        include Celluloid
        include Configurable

        actor_accessor :broker, link: true
      end
    end

    # This should be a Message object with a sender, transport, and parts
    def dispatch(identity, *parts)
      Logger.debug "received from #{identity}: #{parts.inspect}"
      message = Message.parse(parts)
      message.from = identity #TODO Node object? Node might not exist for every sender
      message.transport = Actor.current
      broker.async.dispatch(message)
    end

    def write(message)
      raise NotImplementedError, "write not implemented"
    end
  end
end
