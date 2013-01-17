require 'telecine/failure_detector'

module Telecine
  class Node
    include Celluloid
    include Celluloid::FSM
    include Celluloid::Notifications

    CHECK_INTERVAL = 1 #TODO config

    #TODO add a Callbacks module that other actors can use
    #like Registry::Callbacks
    state :unknown, default: true
    state :up do
      notify_state(:up)
    end
    state :down do
      notify_state(:down)
    end

    # Need an address class that is like a uri
    attr_accessor :id, :address, :fd

    def initialize(id=nil, address=nil, options = {})
      super()
      @id = id
      @address = address
      @fd = FailureDetector.new
      attach Actor.current
    end

    def beat_heart(heartbeat=nil)
      if heartbeat
        # TODO heartbeat info
        # possible heartbeat encryption
      end

      if @fd.empty?
        @timer = every(CHECK_INTERVAL) { check }
      end
      @fd.add(Time.now.to_i)
    end

    def check
      if @fd.suspicious?
        transition :down if state != :down
      else
        transition :up if state != :up
      end
    end

    def notify_state(state)
      Logger.info "#{@id} #{state}"
      publish("telecine.node.state.#{@id}", state)
    end

    # overridden because inspect causes stack overflow
    # TODO why?
    def inspect
      "Node id:#{@id} address:#{@address}"
    end

    def reference_to(actor, router=:router)
      # TODO mailbox references
      Reference.new(id, actor, router)
    end

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
        router.cast(@node_id, @name, method, *args)
      end

      def router
        @router.is_a?(Symbol) ? Celluloid::Actor[@router] : @router
      end
    end
  end
end
