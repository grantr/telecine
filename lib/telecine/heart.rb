module Telecine
  class Heart
    include Celluloid
    include Configurable

    config_accessor :notifier
    self.notifier = :remote_notifier

    HEARTBEAT = 1 #TODO setting

    def initialize
      every(HEARTBEAT) { beat }
    end

    # heartbeat should include a list of referenceable actors and other things
    # if heartbeat is encrypted, stethoscope should still work but it should ignore any data
    def beat
      Logger.trace "beat heart #{Node.id} #{Time.now.to_i}"
      notifier.async.publish("telecine.heartbeat", Node.id, Router.endpoint, Time.now.to_i.to_s)
    end

    def notifier
      config.notifier.is_a?(Symbol) ? Celluloid::Actor[config.notifier] : config.notifier
    end
  end
end
