module Telecine
  # Referenceable should:
  #   - be included into actors that want to be remote-callable
  #   - have start and stop methods
  #   - run a dispatch loop that listens for messages from the transport
  #   - add start and stop methods that start/stop the dispatch loop
  module Referenceable
    def register
    end

    def start
      async.listen_for_messages
    end

    def stop
      #TODO send a stop message
    end

    def listen_for_messages
      loop do
        message = receive { |msg| message.is_a?(Message) }
        puts "got a message in referenceable: #{message}"
        
        Celluloid::Actor.current.mailbox << message.payload
        # TODO replies
      end
    end
  end
end
