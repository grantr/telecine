require 'telecine/reference'
require 'telecine/message_handlers'

module Telecine
  class MailboxNotFound < StandardError; end

  module Broker
    def self.included(base)
      base.class_eval do
        include Celluloid
        include Configurable

        config_accessor :request_timeout
        self.request_timeout = 60
      end
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

    #TODO this should be a registry of type => handler class
    def handler_for(message)
      case message.type
      when :cast
        Cast
      when :call
        Call
      when :reply
        Reply
      else
        Logger.warn("Could not find handler for #{message.type}")
      end
    end

   #TODO this should dereference supervisors
    def mailbox_for(reference)
      reference = registry.get(reference)
      Logger.debug("got #{reference.inspect} as #{reference}")

      reference if reference && reference.alive?
    end

    def encoder
      @encoder ||= BasicEncoder.new
    end

    # Receive a message from a transport and send it to a local actor.
    #TODO dispatch the other way (on the sending end) is handled by References
    # who should handle finding the mailbox? the handler or the broker?
    # probably the handler if possible
    # that allows different message types to use different mailbox finders
    def dispatch(message)
      mailbox = mailbox_for(message)
      return unless mailbox #TODO error handling
      
      handler = handler_for(message.type)
      return unless handler #TODO error handling

      # should the handler get a ref to the broker?
      reply = nil
      begin
        request = future { handler.load(encoder.decode(message)).dispatch(mailbox) }
        reply = request.value(request_timeout)
      rescue => e
        #TODO replace with real timeout exception when Celluloid::Future gets it
        if e.message = "Timed out"
          Logger.warn("Dispatch timed out")
        else
          raise e
        end
      end

      unless reply.nil?
        #TODO handle dead transport or transport error
        #This is a bit messy. Seems like something else should be responsible for creating the reply.
        # or at least, allow the reply class or handler to be configurable.
        # same with transport.
        reply_message = Reply.create(message)
        reply_message.parts = reply
        #TODO this should maybe be a future
        message.transport.async.write(reply_message)
      end
    end

    # This should be another actor
    def find(query)
      raise NotImplementedError, "find is not implemented"
    end

    #TODO get references
  end
end
