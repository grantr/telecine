require "telecine/version"

require 'celluloid'
require 'celluloid/zmq'

module Telecine
  Logger = Celluloid::Logger
end

module Celluloid
  class ActorProxy
    # to avoid circular inspect
    def inspect
      "#<Celluloid::Actor(#{@klass})>"
    end
  end
end

require 'telecine/registry'
require 'telecine/configuration'
require 'telecine/serializer'

require 'telecine/node'

require 'telecine/transport'
require 'telecine/referenceable'
require 'telecine/reference'


# require 'telecine/notifier'
# require 'telecine/broker'
# require 'telecine/router'

#TODO these should move to discovery
# require 'telecine/client'
# require 'telecine/server'
# 
# require 'telecine/boot'
