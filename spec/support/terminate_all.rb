module TerminateAll
  def terminate_all(klass)
    Celluloid::Actor.all.each { |a| a.terminate if a.class == klass && a.alive? }
  end
end
