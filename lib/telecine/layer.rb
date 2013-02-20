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

  class LayerStack
    # should:
    #   be a supervisor group
    #   supervise layers
    attr_accessor :layers

    def initialize(name, &block)
      @layers = []
      configure(&block) if block_given?
    end

    def configure(&block)
      builder = Builder.new(&block)
      @layers += builder.layers
      connect
    end

    # doubly link the list
    def connect
      @layers.inject(@layers.first) do |a, b|
        # skip the first element
        if a === b
          b
        else
          b.down = a
          a.up = b
        end
      end
      self
    end

    class Builder
      attr_accessor :layers
      def initialize(&block)
        @layers = []
        instance_eval(&block) if block_given?
      end

      def layer(klass, *args, &block)
        @layers.push(klass.new(*args, &block))
      end
    end
  end
end
