module Telecine
  class Dispatcher
    include Celluloid

    def registry
      @registry ||= Registry.new
    end

    # this class takes care of finding actors to dispatch method calls to, and returning the result if necessary.
    # it manages actors publishing capabilities and external capabilities incoming from the router. It hands out capabilities to remote nodes (ie bootstrap)
    #
    # actors publish which methods they want accessible, and any parameters

    def register(actor, reference_id)
      Logger.debug("registering #{actor.mailbox.inspect} as #{reference_id}")
      registry.set(reference_id, actor.mailbox)
    end

    def call(reference_id, method, *args)
      Logger.debug("got call: #{reference_id}, #{method}, #{args.inspect}")
      if mailbox = find_mailbox(reference_id)
        Celluloid::Actor.call(mailbox, method, *args)
      end
    end

    def cast(reference_id, method, *args)
      if mailbox = find_mailbox(reference_id)
        Celluloid::Actor.async(mailbox, method, *args)
      end
    end

    #TODO this should dereference supervisors
    def find_mailbox(reference_id)
      Logger.debug "looking for #{reference_id.inspect}"
      Logger.debug "registry is #{registry.inspect}"
      reference = registry.get(reference_id)
      Logger.debug("got #{reference.inspect} as #{reference_id}")

      reference if reference && reference.alive?
    end
  end
end
