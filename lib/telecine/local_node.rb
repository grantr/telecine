module Telecine
  class LocalNode
    include Celluloid

    def call(destination, method, *args)
      if mailbox = find_mailbox(destination)
        Actor.call(mailbox, method, *args)
      end
    end

    def cast(destination, method, *args)
      if mailbox = find_mailbox(destination)
        Actor.async(mailbox, method, *args)
      end
    end

    def find_mailbox(destination)
      actor = Actor[destination]
      actor && actor.alive? ? actor.mailbox : nil
      #TODO return a mailbox if asked
    end

  end
end
