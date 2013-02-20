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

    attr_accessor :node_id, :mailbox_id

    def self.parse(string)
      uri = URI.parse(string)
      new(uri.user, uri.host)
    end

    def initialize(mailbox_id, node_id)
      @mailbox_id = mailbox_id
      @node_id = node_id
    end
  end
end
