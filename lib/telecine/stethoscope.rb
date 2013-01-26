require 'telecine/node'

module Telecine
  class Stethoscope
    include Celluloid
    include Configurable

    config_accessor :topic
    actor_accessor :notifier
    self.notifier = :remote_notifier
    self.topic = "telecine.heartbeat"


    def initialize
      link notifier
      notifier.subscribe(Actor.current, /^#{config.topic}/, :record_heartbeat)
    end

    def record_heartbeat(topic, node_id, node_address, heartbeat)
      Logger.trace "recording heartbeat from #{node_id} #{heartbeat}"

      node = Node.registry.get(node_id) { Node.new(node_id, node_address) }
      node.beat_heart(heartbeat)
    end
  end
end
