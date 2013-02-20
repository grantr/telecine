module Telecine
  class Middleware
    attr_reader :args, :block, :name
    
    def initialize(klass, *args, &block)
      @klass = klass
      @args = args
      @block = block
    end

    def build(app)
      klass.new(app, *args, &block)
    end
  end

  class MiddlewareStack
    include Enumerable
    extend Forwardable

    attr_accessor :middlewares
    def_delegators :@middlewares, :each, :size, :last, :[], :delete

    def initialize(*args)
      @middlewares = []
      yield self if block_given?
    end

    def initialize_copy(other)
      self.middlewares = other.middlewares.dup
    end

    def use(*args, &block)
      middleware = Middleware.new(*args, *block)
      middlewares.push(middleware)
    end

    def build(app = nil, &block)
      app ||= block
      raise "MiddlewareStack#build requires an app" unless app
      middlewares.reverse.inject(app) { |a, m| m.build(a) }
    end
  end
end
