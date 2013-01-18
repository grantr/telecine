module Telecine
  class Node
    include Celluloid
    include Celluloid::FSM
    include Celluloid::Notifications

    include Configurable

    config_accessor :id, :check_interval
    self.id = Celluloid::UUID.generate
    self.check_interval = 1

    def self.registry
      @registry ||= Registry.new
    end

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
        @timer = every(config.check_interval) { check }
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
  end
end

require 'telecine/node/failure_detector'
require 'telecine/node/reference'
