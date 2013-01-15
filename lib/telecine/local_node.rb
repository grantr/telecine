module Telecine
  class LocalNode
    include Celluloid

    def call(destination, method, *args)
      # cast then wait for a reply
    end

    def cast(destination, method, *args)
      if mailbox = find_mailbox(destination)
        Actor.async(mailbox, method, *args)
      end
    end

    def find_mailbox(destination)
      actor = Actor[destination]
      actor && actor.alive? ? actor.mailbox : nil
    end

  end
end
