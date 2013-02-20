module Telecine
  # The Negotiator should:
  #   - take a node id and mailbox to write to
  #   - listen for messages to its own mailbox
  #   - when Negotiation is completed, it should register a middleware stack to
  #     be used for this node and terminate
  #   - handle all messages received from the node while negotiation is taking
  #     place and optionally drop or enqueue them. When Negotiation is finished,
  #     the Negotiator can decide whether to re-enqueue messages to the transport.
  #   - Time out Negotiation eventually and terminate
  class Negotiator

    #TODO state machine

    #TODO build middleware stack
    
    #TODO drop or enqueue incoming messages

    #TODO protocol flows
    
    #TODO register middleware stack

  end
end
