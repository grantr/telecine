#TODO Heart and Stethoscope should move into a separate gem, maybe telecine-disco-broadcast.
# This is only one discovery mechanism of many.
# extract common behavior into Introducer module (is there any?)
# extract heartbeats into transports and nodes
module Telecine
  class Heart
    include Celluloid
    include Configurable

    config_accessor :heartbeat_interval, :topic
    actor_accessor :notifier
    self.notifier = :remote_notifier
    self.heartbeat_interval = 1
    self.topic = "telecine.heartbeat"

    def initialize
      every(config.heartbeat_interval) { beat }
    end

    # heartbeat should include a list of referenceable actors and other things
    # if heartbeat is encrypted, stethoscope should still work but it should ignore any data
    def beat
      Logger.trace "beat heart #{Node.id} #{Time.now.to_i}"
      notifier.async.publish(config.topic, Node.id, Router.endpoint, Time.now.to_i.to_s)
    end
  end
end
