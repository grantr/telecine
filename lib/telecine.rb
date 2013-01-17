require "telecine/version"

require 'celluloid'
require 'celluloid/zmq'

require 'telecine/registry'
require 'telecine/configuration'

require 'telecine/node'
require 'telecine/notifier'
require 'telecine/router'

module Telecine
  include Configurable

  class << self
    def nodes
      @nodes ||= Registry.new
    end
  end

  Logger = Celluloid::Logger
end

require 'telecine/client'
require 'telecine/server'

require 'telecine/boot'
