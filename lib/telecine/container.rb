require 'telecine/layer'

module Telecine
  class Container
    include Layer

    attr_accessor :stack
    def stack
      @stack ||= [Encoder.new, Dispatcher.new]
    end

    def pull_up(request)
      stack.each do |middleware|
        middleware.call(request)
      end
      request.dispatch

      push_down(request)
    end

    class Dispatcher

      def call(request)
        request.before_dispatch do
          puts "dispatching request: #{request.inspect}"
        end
      end
    end

    class Encoder

      def call(request)
        request.before_dispatch do
          request.body = request.body.collect(&:upcase)
        end
      end
    end
  end
end
