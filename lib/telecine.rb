require "telecine/version"

require 'celluloid'
require 'celluloid/zmq'

require 'telecine/registry'
require 'telecine/configuration'
require 'telecine/configuration/local_node'
require 'telecine/remote_notifications'

require 'telecine/node'
require 'telecine/node_registry'
require 'telecine/router'

module Telecine
  include Configurable

  class << self
    def node
      @node ||= Configuration::LocalNode.new
    end

    def nodes
      @nodes ||= NodeRegistry.new
    end
  end

  Logger = Celluloid::Logger
end

require 'telecine/client'
require 'telecine/server'

require 'telecine/boot'
