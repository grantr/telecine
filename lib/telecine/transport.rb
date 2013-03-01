require 'telecine/envelope'
require 'telecine/resolver'
require 'telecine/remote_mailbox'
require 'telecine/mailbox_router'
require 'telecine/middleware'
require 'telecine/negotiator'

module Telecine
  # the Transport should:
  #   - have an address
  #   - read packets off the wire and translate them into Messages
  #   - read messages from its own mailbox to be sent onto the wire
  #   - create mailboxes for references and referenceables to use
  #   - get mailboxes from the resolver
  #   - add middleware to mailboxes to do translation
  #   - cache mailboxes for destinations
  #   - when connecting to a new node, start up a Negotiator and let it run
  #     to completion. While that is running, send all messages from the node
  #     to the Negotiator. When negotiation is complete, the Negotiator will
  #     register a middleware stack to use for that node and optionally re-enqueue
  #     messages received during negotiation.
  #   - always send messages to remote nodes that are under negotiation. The
  #     remote end is free to drop or hold these messages until negotiation is
  #     complete.
  #   - register middleware stacks for connected nodes. Negotiators create and
  #     register these stacks.

  module Transport
    def self.included(base)
      base.class_eval do
        include Celluloid
      end
    end

    attr_accessor :resolver
    attr_accessor :address

    def start
      async.run
    end

    def stop
      #TODO send stop message
    end

    def run
      loop do
        envelope = receive { |msg| msg.is_a?(Envelope) }

        puts "Transport #{address} received envelope: #{envelope.inspect}"

        # This shouldn't be necessary - the Envelope should already have a sender.
        # That allows relays to send envelopes with senders that are not this node.
        envelope.sender = address
        write(envelope)
      end
    end

    def connections
      @connections ||= {}
    end

    def dispatch(envelope)
      puts "Transport dispatching #{envelope.inspect}"
      
      # This should probably be a factory
      connections[envelope.sender] ||= Connection.new(envelope.sender, Celluloid::Actor.current)

      connection = connections[envelope.sender]
      
      mailbox = resolver.resolve(envelope)

      connection.dispatch(envelope, mailbox)
    end

    def resolver
      @resolver ||= BasicResolver.new
    end

    def resolve_mailbox(message)
      mailbox = resolver.resolve(message)
      router_for(mailbox)
    end

    def start_negotiator(message)
      #TODO
      puts "no negotiator found, adding middleware stack"
      connections[message.sender] = MiddlewareStack.new
      dispatch(message)
    end

    def router_for(mailbox)
      MailboxRouter.new(mailbox).tap do |proxy|
        proxy.stack = []
      end
    end

    def remote_mailbox_for(address)
      RemoteMailbox.new(address, Celluloid::Actor.current.mailbox).tap do |proxy|
        proxy.stack = []
      end
    end

    #TODO translator middleware
    
    #TODO mailbox registry
    
    #TODO node state registry (middleware stack or negotiator)
  end
end
