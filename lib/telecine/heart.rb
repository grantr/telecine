module Telecine
  class Heart
    include Celluloid
    include Configurable

    config_accessor :notifier, :heartbeat_interval, :topic
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

    def notifier
      config.notifier.is_a?(Symbol) ? Celluloid::Actor[config.notifier] : config.notifier
    end
  end
end
