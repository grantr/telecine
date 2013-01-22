module Telecine
  class Dispatcher
    include Celluloid

    # this class takes care of finding actors to dispatch method calls to, and returning the result if necessary.
    # it manages actors publishing capabilities and external capabilities incoming from the router. It hands out capabilities to remote nodes (ie bootstrap)
    #
    # actors publish which methods they want accessible, and any parameters

    def call(destination, method, *args)
      if mailbox = find_mailbox(destination)
        Celluloid::Actor.call(mailbox, method, *args)
      end
    end

    def cast(destination, method, *args)
      if mailbox = find_mailbox(destination)
        Celluloid::Actor.async(mailbox, method, *args)
      end
    end

    def find_mailbox(destination)
      actor = Celluloid::Actor[destination.to_sym]
      actor && actor.alive? ? actor.mailbox : nil
      #TODO return a mailbox if asked
    end
  end
end
