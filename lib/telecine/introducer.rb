module Telecine
  module Introducer
    def self.included(base)
      base.class_eval do
        include Celluloid
        include Celluloid::Notifications
        include Configurable

        config_accessor :context
      end
    end
    # Introducers should:
    #   subscribe to changes in context state
    #     context could potentially have a State object that introducers get
    #   be allowed to attach transports
    #   optionally be layers in order to attach transports
    #   
    #   install node registry callbacks that add, remove, or change nodes
    #   
    #   Interactions between multiple introducers might mean that contexts need to
    #   be responsible for arbitration (flapping introducers)
    #
    #   This might be solvable with rules for what introducers can remove, or 
    #   ownership information
    #
    #   Perhaps introducers can add state objects to nodes, and nodes can decide
    #   what data they want to accept. These state objects might have their own
    #   state machines to track individual lifecycle (staleness, recent changes)
    #   
    #   Nodes might have simple hierarchies that allow more authoritative introducers
    #   to override less trusted ones. They might also add a recency weight to introducers.
    #
    #   This is probably functionality that should not be handled by the node
    #   object itself, but is delegated to a sort of state manager.
    #
    #
    #   Introducers publish updates to subobjects owned by each node. These subobjects use versioned
    #   vectors to ensure that stale data doesn't cause issues. (lww-set or or-set from meangirls)
    #
    #   What are some of the things introducers need to learn and tell about nodes?
    #     - node ids
    #     - node keys
    #     - node address urls (tc+zmq, tc+ws, etc)
    #     - transport information, including for each transport:
    #         - keys
    #         - addresses
    #         - encryption protocols
    #         - compression protocols
    #         - encoding protocols
    #     - global (all transports) protocol support, if available
    #     - state information (up, down, etc)
    #     - application-level data including:
    #       - services offered
    #
    #  Nodes should publish state objects for introducers to publish to other
    #  nodes. State objects should serialize to primitive types so they are
    #  easily serialized.
  end

  class LocalIntroducer
    include Introducer
    include Registry::Callbacks

    config_accessor :remote_context

    def start
      # watch remote_context.nodes for changes
      @watcher = on_update remote_context.nodes do |key, previous, current|
        case action
        when :set
          #TODO publish a node update
        when :remove
          #TODO publish a node delete
        end
      end
    end

    def stop
      @watcher.cancel
    end
  end
end
