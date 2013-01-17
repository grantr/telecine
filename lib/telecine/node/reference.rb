module Telecine
  class Node
    class Reference
      attr_accessor :node_id, :name, :router

      def initialize(node_id, name, router=:router)
        @node_id = node_id
        @name = name
        @router = router
      end

      # call a method and wait for the response
      def call(method, *args)
        router.call(@node_id, @name, method, *args)
      end

      # cast a method without waiting for the response
      def cast(method, *args)
        router.async.cast(@node_id, @name, method, *args)
      end

      def router
        @router.is_a?(Symbol) ? Celluloid::Actor[@router] : @router
      end
    end
  end
end
