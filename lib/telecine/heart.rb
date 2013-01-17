module Telecine
  class Heart
    include Celluloid
    include Telecine::RemoteNotifications

    HEARTBEAT = 1 #TODO setting

    def initialize
      every(HEARTBEAT) { beat }
    end

    # heartbeat should include a list of referenceable actors and other things
    # if heartbeat is encrypted, stethoscope should still work but it should ignore any data
    def beat
      Logger.trace "beat heart #{Node.id} #{Time.now.to_i}"
      remote_publish("telecine.heartbeat", Node.id, Router.endpoint, Time.now.to_i.to_s)
    end
  end
end
