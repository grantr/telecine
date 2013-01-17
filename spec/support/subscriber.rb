class Subscriber
  include Celluloid

  attr_accessor :events

  def initialize
    @events = []
  end

  def subscribe(topic)
    Celluloid::Notifications.notifier.subscribe(Actor.current, topic, :dispatch)
  end

  def dispatch(topic, *args)
    @events << args
  end
end
