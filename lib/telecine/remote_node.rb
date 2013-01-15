require 'telecine/failure_detector'

module Telecine
  class RemoteNode
    include Celluloid
    include Celluloid::FSM
    include Celluloid::Notifications

    CHECK_INTERVAL = 1 #TODO config

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


    # TODO method dispatch
    # calls come here first (from referenceables or the router)
    # if this is the local node (Telecine.node.id == @id) then call the method on the 
    # name or mailbox and wait for the result
    # otherwise, this is a remote node, so forward the request to a router and wait for the reply (use futures to time out)
    # (casts that don't need a reply need to be separate so that we don't create a condition for them)
    #
    
    module MethodDispatch
      def local?
        Celluloid::Actor.current == Telecine.nodes.local
      end

      def call(destination, method, *args)
        # cast then wait for a reply
      end

      def cast(destination, method, *args)
        if local?
          if mailbox = find_mailbox(destination)
            Celluloid::Actor.async(mailbox, method, *args)
          end
        else
          Logger.debug "forward to router: #{destination} #{method} #{args.inspect}"
          # forward to router
        end
      end

      def find_mailbox(destination)
        actor = Celluloid::Actor[destination]
        actor && actor.alive? ? actor.mailbox : nil
      end
    end
    include MethodDispatch
    
  end
end
