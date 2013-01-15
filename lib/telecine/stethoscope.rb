require 'telecine/remote_node'

module Telecine
  class Stethoscope
    include Celluloid
    include Telecine::RemoteNotifications

    def initialize
      remote_subscribe(/^telecine.heartbeat/, :record_heartbeat)
    end

    def record_heartbeat(topic, node_id, node_address, heartbeat)
      Logger.trace "recording heartbeat from #{node_id} #{heartbeat}"

      #TODO possible race condition from other node sources
      unless node = Telecine.nodes.get(node_id)
        node = Telecine.nodes.set(node_id, RemoteNode.new(node_id, node_address))
      end

      node.beat_heart(heartbeat)
    end
  end
end
