require 'telecine/reference'

module Telecine
  class MailboxNotFound < StandardError; end

  module Broker
    def self.included(base)
      base.send(:include, Celluloid)
      base.send(:include, Configurable)
    end

    def registry
      @registry ||= Celluloid::Registry.new
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

    def call(call)
      Logger.debug("got call: #{call.destination}, #{call.method}, #{call.args.inspect}")
      if mailbox = find_mailbox(call.destination)
        Celluloid::Actor.call(mailbox, call.method, *call.args)
      else
        abort MailboxNotFound.new
      end
    end

    def cast(cast)
      Logger.debug("got cast: #{cast.destination}, #{cast.method}, #{cast.args.inspect}")
      if mailbox = find_mailbox(cast.destination)
        Celluloid::Actor.async(mailbox, cast.method, cast.args)
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

    def find(query)
      raise NotImplementedError, "find is not implemented"
    end

    #TODO get references
  end

  # extract common behavior into Broker module
  # rename this to InsecureBroker
  class InsecureBroker
    include Broker

    # only allow remote calls to public methods (this is already the celluloid default)
    # not really sufficient, since we might want local actors to call methods
    # that remote actors cannot access
    #
    # need a real system for denoting remote vs public methods

    # this class takes care of finding actors to dispatch method calls to, and returning the result if necessary.

    def find(registered_name)
      if registry.get(registered_name)
        Reference.new(Node.id, registered_name)
      end
    end

  end
end
