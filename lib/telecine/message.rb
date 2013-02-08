require 'telecine/callbacks'

module Telecine
  class InvalidMessageError < StandardError; end

  # This is the interface between transports and brokers
  # headers are for transport use, they probably shouldn't be exposed to the brokers
  # Message should handle encoding/decoding with encoders
  class Message
    include Callbacks
    # Message should have an encoder registry like Mime::Type
    # Should drop the type field and use headers instead
    # the headers should mostly be hashes. still need a headers array to accept
    # multiple copies of the same header.
    # Content-Type,Content-Encoding
    # Some headers should be standard so that transports can use them to communicate.
    #
    # Parts should probably be tagged with Content-type.
    # replies should not be a separate message - they should be the same message with altered address and parts. replies should have the same message id.

    attr_accessor :id, :headers, :body

    attr_accessor :response

    # Things like from, to, and transport should be part of env
    # attr_accessor :from, :to # node ids
    # attr_accessor :transport
    attr_accessor :env

    def headers
      @headers = []
    end

    def id
      @id ||= Celluloid::UUID.generate
    end

    def body
      @body ||= []
    end

    def env
      @env ||= {}
    end

    def dispatch
      run_callbacks(:dispatch) do
        Logger.debug "dispatching"
      end
    end

    define_callbacks :dispatch, :before, :after
  end
end
