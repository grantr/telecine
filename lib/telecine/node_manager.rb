module Telecine
  # Manage nodes we're connected to
  class NodeManager
    include Celluloid::ZMQ
    include Enumerable

    attr_reader :gossip_rate, :heartbeat_timeout

    def initialize
      @nodes = {}

      @gossip_rate       = 5  # How often to send gossip in seconds
      @heartbeat_timeout = 10 # How soon until a lost heartbeat triggers a node partition
      each { |node| node.socket if node } # Connect all so we can gossip
      @gossip = after(gossip_rate) { gossip_timeout }
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

    # Send gossip to a random node (except ourself) after the given interval
    def gossip_timeout
      nodes = select { |node| node.state == :connected }
      peer = nodes.select { |node| node.id != Telecine.id }.sample(1)[0]
      if peer
        nodes = nodes.inject([]) { |a,n| a << [n.id, n.addr, n.timestamp]; a }
        data = nil
        if Telecine.registry.is_a? Registry::GossipAdapter
          data = peer.fresh? ? Telecine.registry.values : Telecine.registry.changed
        end
        Telecine.me.tick
        peer.send_message Telecine::Message::Gossip.new nodes, data
      end
      @gossip = after(gossip_rate) { gossip_timeout }
    end

    def handle_gossip(peers, data)
      peers.each do |id, addr, timestamp|
        if (node = find(id))
          node.handle_timestamp! timestamp
        else
          Directory[id] = addr
          Celluloid::Logger.info "Found node #{id}"
        end
      end
      if Telecine.registry.is_a? Registry::GossipAdapter
        data.map { |data| Telecine.registry.observe data } if data
      end
    end
  end
end
