require 'celluloid/zmq/notifier'

module Telecine
  module RemoteNotifications
    def self.notifier
      Celluloid::Actor[:remote_notifier]
    end

    def remote_notifier
      Telecine::RemoteNotifications.notifier
    end

    def remote_publish(pattern, *args)
      Telecine::RemoteNotifications.notifier.async.publish(pattern, *args)
    end

    def remote_subscribe(pattern, method)
      link remote_notifier
      Telecine::RemoteNotifications.notifier.subscribe(Celluloid::Actor.current, pattern, method)
    end

    def remote_unsubscribe(*args)
      Telecine::RemoteNotifications.notifier.unsubscribe(*args)
    end
  end

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
