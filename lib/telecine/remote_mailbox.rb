require 'telecine/envelope'

module Telecine
  # The RemoteMailbox should:
  #   - proxy messages sent to the remote mailbox to another, intermediate mailbox (like a transport)
  #   - store the address of the remote mailbox
  #   - have a middleware stack that packages payloads into messages
  #   - be serializable and transportable to remote nodes
  #   - be routable through multiple nodes
  #
  # This should be a mailbox proxy (like DCell::Proxy) that delivers all
  # messages to a proxy mailbox. It has an address that the transport uses as a sender id.
  #
  # This is used by the server transport as a way to route messages back to
  # the proper node. The transport creates a mailbox (or retrieves it from 
  # cache) and sends it on to the broker. broker sends replies back. Mailbox
  # takes care of message translation with middleware and forwards replies to
  # the transport.
  #
  # possibly the broker can do something similar for incoming messages: the
  # transport asks the broker for a mailbox for an actor. broker returns a mailbox
  # or nothing. mailbox has all the proper middleware and forwards to real mailbox
  # mailbox can be cached by the transport.
  # 
  # There are two types of destinations:
  #   - the mailbox the message is intended for.
  #   - the next node in the list of nodes the message must pass through to reach
  #   its destination.
  #
  # Mailboxes that are serialized should carry their routing information with
  # them in order to avoid reimplementing a routing layer.
  #
  # Normally there will only be one node in the list of nodes, however routed
  # messages might pass through multiple nodes on their way to their destination.
  #
  # client transports have a registry that stores the list of mailboxes and
  # their addresses. Messages to mailboxes are dispatched directly.
  # mailboxes have a list of call ids and tasks to resume.
  # each node has a registry that stores the calls in flight in a hash with mailboxes.
  #
  #
  # Now both ends have mailboxes attached directly to transports. Server and
  # client transports do roughly the same thing:
  #   * Messages from the wire get a destination lookup and are forwarded 
  #     there. Optionally a mailbox resolution handler can be executed.
  #   * Messages from local actors come from mailbox proxies. These will be prepackaged
  #     by the proxies so that all the transport has to do is generate a wire
  #     format and send.
  #
  # Expanded flow:
  #   1. Reference gets a method call. Its mailbox (given to it by the
  #      transport) receives the call, turns it into a message packet, and
  #      forwards it to the transport
  #   2. The transport gets the Message from the mailbox, translates
  #      it into the wire format and sends it to the destination.
  #   3. The server transport gets the message from the wire and turns it into
  #      a Message. It looks up the destination it its cache. If the destination
  #      is not cached, it forwards the message to the mailbox resolver.
  #   4. The mailbox resolver tries to find a mailbox for the message. If
  #      successful, it returns the mailbox. If not, it returns an error.
  #      The returned mailbox may itself be a mailbox proxy with its own middleware.
  #   5. In the success case, the transport wraps the given mailbox in a mailbox 
  #      proxy and caches it.
  #   6. The transport creates and caches a reply mailbox and sends both the
  #      message and reply proxy to the destination mailbox.
  #
  #      TODO how are error responses cached? Can the resolver pre-cache mailboxes
  #      with the transport?
  #
  #   7. The recipient actor runs a loop that watches for messages from the
  #      transport. This loop receives the message and reply mailbox and
  #      dispatches internally to the recipient actor. Replies are enqueued
  #      into the reply mailbox.
  #   8. The transport receives a Message from the reply mailbox. It translates
  #      it into the wire format and sends it to the destination.
  #   9. The client transport receives a message on the wire and turns it into
  #      a Message. It looks up the destination in its cache. If the destination
  #      is not cached, it forwards the Message to a Resolver which returns a
  #      mailbox. The client transport wraps that mailbox in a proxy and stores
  #      it in its address registry.
  #   10. The client transport sends the Message to the mailbox proxy. Note
  #       that this will be a different proxy than the one owned by the Reference.
  #       It proxies the mailbox of the actor that sent the message to the
  #       Reference.
  #
  #
  class RemoteMailbox
    attr_accessor :stack
    attr_accessor :forwarder, :address

    def initialize(address, forwarder)
      @address = address
      @forwarder = forwarder
    end

    def <<(message)
      transport_message = Envelope.new
      transport_message.destination = @address
      transport_message.payload = message
      puts "forwarding outgoing message #{transport_message.inspect} to #{@forwarder.inspect}"
      @forwarder << transport_message
    end
  end
end
