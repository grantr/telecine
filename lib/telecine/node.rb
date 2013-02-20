require 'telecine/layer'
require 'telecine/reference'

module Telecine

  class Node
    # Nodes should:
    #   contain node configuration and state
    #   be shareable and serializeable
    #   contain everything a remote node needs to connect to this node
    #   generate references to remote actors
    #   contain layer stacks for transports and routers (basically remote contexts)
    #   these layer stacks:
    #     have middleware that send requests from references to the remote through transports
    #     have middleware that route responses from the remote to references
    #   - be serializable
    #   - contain everything a remote node needs to connect to this node
    #   - publish updates locally
    #   - use CRDTs to aggregate data from multiple sources
    #
    #   examples of items contained:
    #   node id
    #   node keys
    #   transport information:
    #     for each transport key, including * for all transports, a hash containing:
    #       keys
    #       addresses
    #       encryption protocols
    #       compression protocols
    #       encoding protocols
    #   state information (up, down, etc)
    #   application-level data
    #
    # Maybe Node should be this state object, and there should be a subobject (layer) for routing?
    #
    # REMEMBER! Node is a representation of a remote node, not the local node.
    # The Context is the source of information about the local node.
    #
    # Context needs to either have its own information container, or maintain a
    # local Node object that can produce a state. It would be nice if Node was
    # generic enough that it could be used as a local node.
    #
    # Nodes should support multiple addresses, which is effectively multiple transports.
    #
    # address format:
    # tcs+zmq://dfoxds7usmsxflijq2ddfgkp44pa3dehlrr6cjjty3q3gsookt7a@127.0.0.1:5900
    # ciphersuite+transport://node_id@host:port
    #
    # ciphersuite, transport = uri.scheme.split("+")
    # node_id, host, port = uri.user, uri.host, uri.port
    #

    include Configurable

    config_accessor :id
    config_accessor :addresses
    self.addresses = []

    def initialize(id=nil, options = {})
      self.id = id || Celluloid::UUID.generate
    end
  end
end
