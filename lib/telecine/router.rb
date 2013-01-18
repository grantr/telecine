require 'celluloid/zmq/router'

module Telecine
  class Router < Celluloid::ZMQ::Router
    include Configurable
    include Registry::Callbacks

    config_accessor :endpoint

    def initialize(*args)
      super

      on_set config, :endpoint do |previous, current|
        add_endpoint(current)
      end

      on_remove config, :endpoint do |previous, current|
        respond_to?(:remove_endpoint) ? remove_endpoint(previous) : Logger.warn("Cannot remove endpoint: #{previous}")
      end

      on_set Node.config, :id do |previous, current|
        @identity = current
        # binds and connects must be reset to get the new identity
        if respond_to?(:remove_endpoint)
          @endpoints.each do |endpoint|
            Logger.debug "resetting endpoint #{endpoint}"
            remove_endpoint(endpoint)
            add_endpoint(endpoint)
          end
          @peers.each do |peer|
            Logger.debug "resetting peer #{peer}"
            remove_peer(peer)
            add_peer(peer)
          end
        else
          Logger.warn("Cannot reset endpoints and peers")
        end
      end

      on_update Node.registry do |key, action, previous, current|
        case action
        when :set
          Logger.debug "adding peer: #{key} #{current}"
          add_peer(current.address)
        when :remove
          respond_to?(:remove_peer) ? remove_peer(previous.address) : Logger.warn("Cannot remove peer: #{previous.address}")
        end
      end
    end

    def call(identity, destination, method, *args)
      @requests ||= {}
      message = Message.new
      message.headers = ["call"]
      message.parts = [destination, method, *args]
      @requests[message.id] = Condition.new
      write(identity, *message.to_parts)
      @requests[message.id].wait
    end

    def cast(identity, destination, method, *args)
      message = Message.new
      message.headers = ["cast"]
      message.parts = [destination, method, *args]
      write(identity, *message.to_parts)
    end

    def dispatch(identity, parts)
      Logger.debug "received from #{identity}: #{parts.inspect}"

      message = Message.parse(parts)
      Logger.debug "message: #{message.inspect}"

      case message.headers.first
      when "call"
        result = dispatch_call(*message.parts)
        reply = Message.new
        reply.id = message.id
        reply.headers = ["reply"]
        reply.parts = result
        write(identity, *reply.to_parts)
      when "cast"
        dispatch_cast(*message.parts)
      when "reply"
        if @requests && @requests[message.id]
          #TODO use reply-ids
          @requests[message.id].broadcast(message.parts)
        end
      end
    end

    module LocalDispatch

      def dispatch_call(destination, method, *args)
        if mailbox = find_mailbox(destination)
          Celluloid::Actor.call(mailbox, method, *args)
        end
      end

      def dispatch_cast(destination, method, *args)
        if mailbox = find_mailbox(destination)
          Celluloid::Actor.async(mailbox, method, *args)
        end
      end

      def find_mailbox(destination)
        actor = Celluloid::Actor[destination.to_sym]
        actor && actor.alive? ? actor.mailbox : nil
        #TODO return a mailbox if asked
      end
    end
    include LocalDispatch
  end
end

require 'telecine/router/message'
