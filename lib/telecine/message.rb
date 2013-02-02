module Telecine
  class InvalidMessageError < StandardError; end

  # This is the interface between transports and brokers
  # headers are for transport use, they probably shouldn't be exposed to the brokers
  # Message should handle encoding/decoding with encoders
  class Message
    VERSION = "1"

    # Message should have an encoder registry like Mime::Type
    # Should drop the type field and use headers instead
    # the headers should mostly be hashes. still need a headers array to accept
    # multiple copies of the same header.
    # Content-Type,Content-Encoding

    attr_accessor :version, :id, :type, :headers, :parts
    attr_accessor :from, :to
    attr_accessor :transport

    def initialize(*parts)
      @parts = parts
    end

    def headers
      @headers = []
    end

    def id
      @id = Celluloid::UUID.generate
    end

    def type
      @type.to_sym
    end

    def self.load(parts)
      message = allocate
      parts = Array(parts).dup

      message.version = parts.shift
      case message.version
      when VERSION
        message.id = parts.shift
        message.type = parts.shift.to_sym

        while !parts.empty? && (header = parts.shift) != ""
          message.headers << header
        end

        message.parts = parts
      else
        raise InvalidMessageError, "Unknown message version #{message.version}"
      end
    end

    def dump
      [
        VERSION.to_s,
        id.to_s,
        type.to_s,
        *Array(headers).collect(&:to_s), # json?
        "",
        Array(parts).collect(&:to_s)
      ]
    end
  end

  class Reply < Message

    def reply_id
      @headers[0]
    end

    def self.create(message)
      reply = allocate
      reply.type = :reply
      reply.headers << message.id
      reply.to = message.from
      reply
    end
  end
end
