module Telecine
  class InvalidMessageError < StandardError; end

  # This is the interface between transports and brokers
  # headers are for transport use, they probably shouldn't be exposed to the brokers
  # Message should handle encoding/decoding with encoders
  class StreamingMessage
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

    attr_accessor :response, :transport

    # Things like from, to, and transport should be part of env
    # attr_accessor :from, :to # node ids
    # attr_accessor :transport
    attr_accessor :env

    attr_accessor :state

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

    #TODO state machine: :new, :open, :closed, :errored
    def state
      @state ||= :new
    end

    def open
      run_callbacks(:open) do
        @state = :open
        @headers.freeze
      end
    end

    def chunk(*chunks)
      #require_state :new, :open
      run_callbacks(:chunk, chunks) do |mutated_chunks|
        # @handler.chunk(*mutated_chunks)
      end
    end

    def close(flush=true)
      # require_state :open
      run_callbacks(:close) do
        #TODO this should flush all chunks first if flush is true
        @state = :closed
        transport.write_message(self) if transport
      end
    end

    def respond(*response)
      if response
        chunk(*response)
        close
      end
    end

    define_callbacks :open,  :after
    define_callbacks :chunk, :before, :after
    define_callbacks :close, :before, :after
  end
end
