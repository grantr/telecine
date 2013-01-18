require 'telecine/node'

module Telecine
  class Stethoscope
    include Celluloid
    include Configurable

    config_accessor :notifier
    self.notifier = :remote_notifier

    def initialize
      link notifier
      notifier.subscribe(Actor.current, /^telecine.heartbeat/, :record_heartbeat)
    end

    def record_heartbeat(topic, node_id, node_address, heartbeat)
      Logger.trace "recording heartbeat from #{node_id} #{heartbeat}"

      node = Node.registry.get(node_id) { Node.new(node_id, node_address) }
      node.beat_heart(heartbeat)
    end

    def notifier
      config.notifier.is_a?(Symbol) ? Celluloid::Actor[config.notifier] : config.notifier
    end
  end
end
