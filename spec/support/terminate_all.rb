module TerminateAll
  def terminate_all(klass)
    Celluloid::Actor.all.select { |a| a.class == klass && a.alive? }.each(&:terminate)
  end
end
