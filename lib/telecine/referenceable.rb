module Telecine
  # Referenceable should:
  #   - be included into actors that want to be remote-callable
  #   - have start and stop methods
  #   - run a dispatch loop that listens for messages from the transport
  #   - add start and stop methods that start/stop the dispatch loop
  module Referenceable
    def register
    end
  end
end
