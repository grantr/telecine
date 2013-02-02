require 'telecine/transport'
require 'celluloid/zmq/router'

module Telecine
  # specify which protocol this transport handles (zmq)
  # handle heartbeats through this transport
  class ZMQRouter < Celluloid::ZMQ::Router
    include Transport
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
    end

    def broker=(broker)
      super

      @id_cb.cancel if @id_cb
      @nodes_cb.cancel if @nodes_cb

      @id_cb = on_set broker.config, :id do |previous, current|
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

      @nodes_cb = on_update broker.nodes do |key, action, previous, current|
        case action
        when :set
          Logger.debug "adding peer: #{key} #{current}"
          add_peer(current.address)
        when :remove
          respond_to?(:remove_peer) ? remove_peer(previous.address) : Logger.warn("Cannot remove peer: #{previous.address}")
        end
      end
    end


    def write(message)
      super(message.to, *message.dump)
    end

  end
end