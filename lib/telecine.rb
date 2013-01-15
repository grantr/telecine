require 'celluloid'
require 'celluloid/zmq'

Celluloid::ZMQ.init

require 'red25519'

require 'telecine/version'
require 'telecine/actor_proxy'
require 'telecine/directory'
require 'telecine/mailbox_proxy'
require 'telecine/messages'
require 'telecine/node'
require 'telecine/node_manager'
require 'telecine/responses'
require 'telecine/router'
require 'telecine/rpc'
require 'telecine/future_proxy'
require 'telecine/server'
require 'telecine/info_service'

require 'telecine/celluloid_ext'

module Telecine
  class NotConfiguredError < RuntimeError; end # Not configured yet

  DEFAULT_PORT  = 7890 # Default Telecine port
  @config_lock  = Mutex.new

  class << self
    attr_reader :me

    # Configure Telecine with the following options:
    #
    # * id: to identify the local node, defaults to hostname
    # * addr: 0MQ address of the local node (e.g. tcp://4.3.2.1:7890)
    # *
    def setup(options = {})
      # Stringify keys :/
      options = options.inject({}) { |h,(k,v)| h[k.to_s] = v; h }

      @config_lock.synchronize do
        @configuration = {
          'id'   => generate_node_id,
          'addr' => "tcp://127.0.0.1:#{DEFAULT_PORT}"
        }.merge(options)

        @me = Node.new @configuration['id'], @configuration['addr']

        # Specify the directory server (defaults to me), and add it
        # to the local directory.
        directory = @configuration['directory'] || {}
        directory = directory.inject({}) { |h,(k,v)| h[k.to_s] = v; h }
        directory = {
          'id'   => @configuration['id'],
          'addr' => @configuration['addr']
        }.merge(directory)
        Telecine::Directory.set directory['id'], directory['addr']

        addr = @configuration['public'] || @configuration['addr']
        Telecine::Directory.set @configuration['id'], addr
      end

      me
    end

    # Obtain the local node ID
    def id
      raise NotConfiguredError, "please configure Telecine with Telecine.setup" unless @configuration
      @configuration['id']
    end

    # Obtain the 0MQ address to the local mailbox
    def addr; @configuration['addr']; end
    alias_method :address, :addr

    # Attempt to generate a unique node ID for this machine
    def generate_node_id
      Ed25519::SigningKey.generate.to_hex
    end

    # Run the Telecine application
    def run
      Telecine::SupervisionGroup.run
    end

    # Run the Telecine application in the background
    def run!
      Telecine::SupervisionGroup.run!
    end

    # Start combines setup and run! into a single step
    def start(options = {})
      setup options
      run!
    end
  end

  # Telecine's actor dependencies
  class SupervisionGroup < Celluloid::SupervisionGroup
    supervise NodeManager, :as => :node_manager
    supervise Server,      :as => :telecine_server
    supervise InfoService, :as => :info
  end

  Logger = Celluloid::Logger
end
