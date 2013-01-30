require 'telecine/broker'
require 'telecine/reference'

module Telecine
  class InsecureBroker
    include Broker

    # only allow remote calls to public methods (this is already the celluloid default)
    # not really sufficient, since we might want local actors to call methods
    # that remote actors cannot access
    #
    # need a real system for denoting remote vs public methods

    # this class takes care of finding actors to dispatch method calls to, and returning the result if necessary.

    def find(registered_name)
      if registry.get(registered_name)
        Reference.new(Node.id, registered_name)
      end
    end
  end
end
