require 'telecine/message'
module Telecine
  class Request < Message
    def initialize(destination, method, *args)
      super(nil, [], [destination, method, *args])
    end
  end
end
