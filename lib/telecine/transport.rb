require 'telecine/message'
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
      puts "running"
      loop do
        message = receive { |msg| msg.is_a?(Message) }

        puts "#{address} received message: #{message.inspect}"

        message.sender = address
        write(message)
      end
    end

    def mailboxes
      @mailboxes ||= {}
    end

    def connections
      @connections ||= {}
    end

    def dispatch(message)
      dispatch_to_mailbox(message) || start_negotiator(message)
    end

    def dispatch_to_mailbox(message)
      puts "dispatching"
      # if mailbox registry has a mailbox for the address, send to it
      if mailboxes[message.destination]
        puts "mailbox found: #{mailboxes[message.destination]}"
        mailbox = mailboxes[message.destination]
      # if connection registry has a middleware stack for the sender, try to resolve the mailbox
      elsif connections[message.sender].is_a?(MiddlewareStack)
        puts "middleware stack found: #{connections[message.sender]}"
        mailboxes[message.destination] = resolve_mailbox(message) #TODO handle errors
        puts "resolved mailbox: #{mailboxes[message.destination]}"
        mailbox = mailboxes[message.destination]
      # if a negotiator exists for this node, send to that
      elsif connections[message.sender].is_a?(Negotiator)
        puts "negotiator found: #{connections[message.sender]}"
        mailbox = connections[message.sender].mailbox
      end

      if mailbox
        mailbox << message
        true
      end
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
