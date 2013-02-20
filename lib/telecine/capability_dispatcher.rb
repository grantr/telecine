module Telecine
  # there should be a module that allows actors to declaratively define their
  # permissions
  module Referenceable
    # add configuration var for capability path and dispatcher
    # take blocks to define authorize and dispatch behavior (but maybe should just use methods?)
    # probably don't want these behaviors to be chained, so they should be methods
    # in the usual case, we want to authorize specific methods only
    # add default authorize and dispatch methods
    #
    # lets work on the minimum viable product here:
    # dispatcher generates capabilities for actors
    # dispatcher capability comes from config
    # actors are looked up by string
    # actors always authorize
    # capabilities always allow methods

    #TODO what should args be?
    #what information do we have?
    #the identity of the requesting node
    #the name pattern requested
    #possibly the scopes requested
    def authorize(*args)
      true
    end


    #TODO what should args be?
    #what information do we have?
    #the identity of the requesting node
    #the capability used
    #the additional info added to the cap
    #the method call and args
    def dispatch(*args)
      true
    end
  end
  #
  class CapabilityDispatcher < Dispatcher
    # This class registers actors by capability. You can only reference an actor
    # if you have a matching capability.
    #
    # actors should not have to know anything about capabilities or how to use them.
    # they just publish themselves with the desired permissions, and the dispatcher
    # takes care of generating caps and distributing them.
    #
    # this allows actors to be compatible with authenticated and non-authenticated
    # dispatchers without code changes.
    #
    #
    #
    #
    # actors publish which methods they want accessible, and any parameters
    # should actors publish what they 'provide' so that clients can search for them?

    def initialize
      register(Actor.current, :dispatcher)
    end

    # this should take a block or method to call when authorizing incoming requests
    # it should be a method, but the declarative module should allow blocks to be called by the method
    # the method should have a default name: authorize
    # if the method returns nil or false, not authorized
    # if it returns true, authorized
    # if it returns something else, authorize but encode the return value in the capability
    # (it will be sent to the actor when deciding whether to dispatch)
    # look at how erlang/akka handle this
    #
    # in erlang:
    # you can only get a reference to a specific actor
    #   this is fine for us, i think we should probably drop name caps anyway. actors can be
    #   persistent by persisting their signing keys (like the dispatcher)
    
    # so here, actors decide what name they want to be discoverable as. other actors can look for actors by string (regex or otherwise) and the registered actors will decide if they want to return references. When using wildcards it is possible to get multiple actors back, this allows something like '*' to return every reference.

    #TODO return the capability
    #TODO allow the capability to be persistent (ie, passed in, or loaded/saved from a path given)
    #
    def register(actor, registered_name, options={})
      super
    end

    # this should also call a method on registered actors to determine if a cap
    # should be returned
    def find(query)
      Capability.generate
    end

  end
end
