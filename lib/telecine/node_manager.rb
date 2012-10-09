module Telecine
  # Manage nodes we're connected to
  class NodeManager
    include Celluloid::ZMQ
    include Enumerable

    def initialize
      @nodes = {}
    end

    # Return all available nodes in the cluster
    def all
      Directory.all.map do |node_id|
        find node_id
      end
    end

    # Iterate across all available nodes
    def each
      Directory.all.each do |node_id|
        yield find node_id
      end
    end

    # Find a node by its node ID
    def find(id)
      node = @nodes[id]
      return node if node

      addr = Directory[id]
      return unless addr

      if id == Telecine.id
        node = Telecine.me
      else
        node = Node.new(id, addr)
      end

      @nodes[id] ||= node
      @nodes[id]
    end
    alias_method :[], :find
  end
end
