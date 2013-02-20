require 'telecine/layer'

module Telecine
  class Container
    include Layer

    attr_accessor :stack
    def stack
      @stack ||= [Router.new, Dispatcher.new]
    end

    def pull_up(request)
      stack.each do |middleware|
        middleware.call(request)
      end
      request.dispatch

      push_down(request.response)
    end

    class Dispatcher

      def call(request)
        request.before_dispatch do
          puts "dispatching request: #{request.inspect} to #{request.env[:mailbox]}"
        end
      end
    end

    class Router

      def call(request)
        request.before_dispatch do
          puts "finding mailbox for #{request.inspect}"
          request.env[:mailbox] = find_mailbox(request)
        end
      end
    end
  end
end
