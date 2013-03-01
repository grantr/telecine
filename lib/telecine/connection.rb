module Telecine
  # A Connection should:
  #   - negotiate the connection parameters
  #   - decide which messages to forward
  #   - maintain the list of mailboxes resolved
  #   - get destination mailboxes from the Resolver
  #   - maintain a single middleware stack to run all messages through
  #
  #   Maybe this should be separate from the Negotiator? Should the Negotiator be
  #   an actor that replaces itself with a Connection object (which is
  #   essentially just a node-specific middleware stack)
  #
  #  The Negotiator should be started by the Connection as needed. The transport does not need to be aware of it.
  #
  
  class Connection
    include Celluloid::FSM

    attr_accessor :sender
    attr_accessor :stack

    def initialize(sender, transport)
      @sender = sender
      @transport = transport
      attach @transport
    end

    #TODO state machine: up, down, etc
    # whenever a message comes in, reset state machine timer
    
    def dispatch(envelope, mailbox=nil)
      puts "dispatching #{envelope.inspect} to #{mailbox.inspect}"

      mailbox << envelope.contents
    end
  end
end
