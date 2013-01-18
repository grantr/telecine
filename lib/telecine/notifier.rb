require 'celluloid/zmq/notifier'

module Telecine
  class Notifier < Celluloid::ZMQ::Notifier
    include Configurable
    include Registry::Callbacks

    config_accessor :peers, :endpoint

    def initialize
      super()

      on_update config, :peers do |action, previous, current|
        case action
        when :set
          respond_to?(:clear_peers) ? clear_peers : Logger.warn("Cannot clear peers")
          current.each { |endpoint| add_peer(endpoint) }
        when :remove_element
          respond_to?(:remove_peer) ? remove_peer(previous) : Logger.warn("Cannot remove peer: #{previous}")
        when :add_element
          add_peer(current)
        when :remove
          respond_to?(:clear_peers) ? clear_peers : Logger.warn("Cannot clear peers")
        end
      end

      on_set config, :endpoint do |previous, current|
        add_endpoint(current)
      end

      on_remove config, :endpoint do |previous, current|
        respond_to?(:remove_endpoint) ? remove_endpoint(previous) : Logger.warn("Cannot remove endpoint: #{previous}")
      end
    end
  end
end
