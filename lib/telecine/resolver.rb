module Telecine
  module Resolver
    # The resolver should:
    #   - take a envelope
    #   - return a mailbox if the envelope is valid and can be delivered
    #   - return an error if the envelope is invalid
    #   - return an error or dead-letter mailbox if the envelope is valid
    #     but cannot be delivered
    #   - add middleware to the mailbox returned (by wrapping the real mailbox
    #     with a proxy mailbox)
    #   - cache mailboxes by address
  end

  class BasicResolver
    include Resolver

    def resolve(envelope)
      mailbox_address = envelope.destination.split("@").first

      puts "looking for mailbox #{mailbox_address}"

      actor = Celluloid::Actor.all.detect { |a| a.mailbox.address == mailbox_address }
      actor.mailbox if actor
    end
  end
end
