require 'uri'

module Telecine
  class NodeAddress
    extend Forwardable

    def_delegators :@uri, :host, :port, :scheme

    attr_accessor :uri

    def self.parse(string)
      new URI.parse(string)

    end

    def initialize(uri)
      @uri = uri
    end

    def node_id
      @uri.user
    end

    def protocol
      @protocol ||= scheme.split("+").first
    end

    def transport
      @protocol ||= scheme.split("+").last
    end
  end

  class MailboxAddress

    attr_accessor :uri

    def self.parse(string)
      new URI.parse(string)
    end

    def initialize(uri)
      @uri = uri
    end

    def node_id
      @uri.host
    end

    def mailbox_id
      @uri.user
    end
  end
end
