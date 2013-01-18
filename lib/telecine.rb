require "telecine/version"

require 'celluloid'
require 'celluloid/zmq'

module Telecine
  Logger = Celluloid::Logger
end

require 'telecine/registry'
require 'telecine/configuration'

require 'telecine/node'
require 'telecine/notifier'
require 'telecine/router'

require 'telecine/client'
require 'telecine/server'

require 'telecine/boot'
