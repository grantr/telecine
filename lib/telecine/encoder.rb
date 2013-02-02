require 'telecine/message'

module Telecine
  module Encoder

    # if this returns a message, how can we use Message subclasses?
    # should this take a message and return a message?
    #
    # Maybe the Message class or instance should be the one doing the encoding?
    def encode(parts)
      Message.new(parts)
    end
    # take a set of parts, return a message

    # take a message, return a set of parts
    def decode(message)
      message.parts
    end
  end
end
