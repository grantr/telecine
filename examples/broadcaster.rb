class Broadcaster
  include Celluloid
  include Telecine::RemoteNotifications

  def broadcast(topic, notification)
    Celluloid::Logger.debug "publishing to #{topic}: #{notification}"
    remote_publish("telecine.broadcast.#{topic}", notification)
  end

end
