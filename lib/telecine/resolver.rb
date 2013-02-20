module Telecine
  module Resolver
    # The resolver should:
    #   - take a message
    #   - return a mailbox if the message is valid and can be delivered
    #   - return an error if the message is invalid
    #   - return an error or dead-letter mailbox if the message is valid
    #     but cannot be delivered
    #   - add middleware to the mailbox returned (by wrapping the real mailbox
    #     with a proxy mailbox)
  end

  class BasicResolver
    include Resolver

    def resolve(message)
      address = message.destination.mailbox_id

      actor = Celluloid::Actor.all.detect { |a| a.mailbox.address == address }
      actor.mailbox
    end
  end
end
