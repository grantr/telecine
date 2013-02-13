require 'telecine/transport'

module Telecine
  module Transport
    class Local
      include Transport
      include Registry::Callbacks
      include Celluloid::Notifications

      config_accessor :channel

      def initialize
        on_set config, :channel do |previous, current|
          if previous
            unsubscribe(channel_topic(previous), :dispatch)
          end
          subscribe(channel_topic(current), :dispatch)
        end

        config.channel = Celluloid::UUID.generate
      end

      def channel_topic(channel=config.channel)
        "telecine.transport.local.#{channel}"
      end

      def address
        channel_topic
      end

      def pull_down(destination, message)
        publish(destination, message)
      end

      def dispatch(topic, message)
        async.push_up(topic, message)
      end
    end
  end

  class DebugLayer
    include Layer

    def pull_up(*args)
      Logger.debug("received: #{args.inspect}")
    end
  end
end
