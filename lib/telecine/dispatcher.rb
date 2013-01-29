require 'telecine/reference'

module Telecine
  class MailboxNotFound < StandardError; end

  class Dispatcher
    include Celluloid
    include Configurable

    config_accessor :registered_name
    self.registered_name = :dispatcher

    # only allow remote calls to public methods (this is already the celluloid default)
    # not really sufficient, since we might want local actors to call methods
    # that remote actors cannot access

    def registry
      @registry ||= Registry.new
    end

    # this class takes care of finding actors to dispatch method calls to, and returning the result if necessary.
    def initialize
      register(Actor.current, config.registered_name)
    end

    # returns the registered_name
    def register(actor, registered_name, options={})
      Logger.debug("registering #{actor.mailbox.inspect} as #{registered_name}")
      registry.set(registered_name, actor.mailbox)
      registered_name
    end

    def unregister(registered_name)
      Logger.debug("unregistering #{registered_name}")
      registry.remove(registered_name)
    end

    def find(registered_name)
      if registry.get(registered_name)
        Reference.new(Node.id, registered_name)
      end
    end

    def call(reference_id, method, *args)
      Logger.debug("got call: #{reference_id}, #{method}, #{args.inspect}")
      if mailbox = find_mailbox(reference_id)
        Celluloid::Actor.call(mailbox, method, *args)
      else
        abort MailboxNotFound.new
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
