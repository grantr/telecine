require 'uri'

module Telecine
  # these should be actors
  # these should handle selecting a transport
  # these should handle encoding and decoding messages
  # references should send requests to brokers, not directly to transports.
  # references should block waiting for broker replies
  # call and cast should be the same object with different type?
  #
  # references create dispatch objects
  class Reference
    attr_accessor :node_id, :name, :router

    # capabilities must be node independent. it must be possible to distribute
    # capabilities to servers and clients without them being tied to server id.
    def initialize(node_id, name, router=:router)
      @node_id = node_id
      @name = name
      @router = router
    end

    # call a method and wait for the response
    def call(method, *args)
      router.call(@node_id, @name, method, *args)
    end

    # cast a method without waiting for the response
    def cast(method, *args)
      router.async.cast(@node_id, @name, method, *args)
    end

    def router
      @router.is_a?(Symbol) ? Celluloid::Actor[@router] : @router
    end

    def to_s
      "tcr://#{node_id}/#{name}"
    end

    def self.parse(string)
      uri = URI.parse(string)
      if uri.scheme == "tcr"
        # strip leading slash
        #TODO send the slash to the dispatcher for hierarchical lookups
        new(uri.host, uri.path.sub(/^\//, ''))
        #TODO should this raise otherwise?
      end
    end
  end
end
