module Telecine
  class Context
    #Context should:
    #  be a supervisor group
    #
    include Configurable

    attr_accessor :stacks
    attr_accessor :nodes

    def initialize(*args, &block)
      @stacks = Registry.new
      @nodes  = Registry.new

      configure(&block) if block_given?
    end

    def configure(&block)
      builder = Builder.new(&block)
      @stacks.merge!(builder.stacks)
    end

    # declarative configuration
    #
    # stack(&block) defines a layer stack
    #
    # inside the layer stack configuration:
    #   use adds a layer (use is aliased to 'layer' to avoid confusion with middleware stacks)
    #   
    #   inside the layer configuration:
    #     use adds a middleware
    #
    # new do
    #   stack do # LayerStack
    #     layer ZmqTransport do # MiddlewareStack
    #       use ZlibCompression
    #       use MsgPackEncoding
    #     end
    #     layer Broker do
    #       use CapabilityAuthorization
    #       use Dispatch
    #     end
    #   end
    # end
    #
    # TODO
    # node transport mappings: zmq => ZmqTransport, ws => WSTransport, etc
    # default node stacks
    # introducers (could just be layer stacks)
    # listen addresses

    #TODO write a Buildable module that can be included in classes that include Configurable.
    # It defines a Builder subclass and a block-style configuration dsl.
    #
    # Builder subclass could maybe be a subclass of Configuration so it gets method missing.
    # This should probably wait until the dsl is working
    #
    class Builder
      attr_accessor :stacks

      def initialize(&block)
        @stacks = {}
        instance_eval(&block) if block_given?
      end

      def stack(name=Celluloid::UUID.generate, &block)
        @stacks[name] = LayerStack.new(name, &block)
      end
    end
  end
end
