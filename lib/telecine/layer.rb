module Telecine
  module Layer
    def self.included(base)
      base.class_eval do
        include Celluloid
        include Configurable

        # down is closer to the network link
        actor_accessor :down

        # up is further from the network link
        actor_accessor :up
      end
    end

    def push_up(*args)
      up.pull_up(*args)

    end

    def push_down(*args)
      down.pull_down(*args)
    end

    def pull_up(*args)
      raise NotImplementedError, "pull_up is not implemented"
    end

    def pull_down(*args)
      raise NotImplementedError, "pull_down is not implemented"
    end

    def inspect
      self.class.name
    end
  end
end
