class Subscriber
  include Celluloid
  include Telecine::RemoteNotifications

  def initialize
    remote_subscribe(/^telecine.broadcast/, :dispatch)
  end

  def dispatch(topic, message)
    Celluloid::Logger.debug "handled broadcast: #{topic} #{message}"
  end
end
