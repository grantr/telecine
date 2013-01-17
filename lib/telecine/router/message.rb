module Telecine
  class Router
    class Message
      VERSION = "1"

      class Envelope
        attr_accessor :id, :headers, :version

        def id
          @id ||= Celluloid::UUID.generate
        end

        def version
          @version ||= VERSION
        end

        def headers
          @headers ||= []
        end

        def self.parse(parts)
          envelope = new
          envelope.version = parts.shift
          #TODO branch on version here

          envelope.id = parts.shift

          while (header = parts.shift) != ""
            envelope.headers << header
          end
          envelope
        end

        def to_parts
          [
            version,
            id,
            *Array(headers).collect(&:to_s), # json?
            ""
          ]
        end
      end

      extend Forwardable
      def_delegators :envelope, :id, :id=, :headers, :headers=, :version, :version=

        attr_accessor :envelope, :parts

      def envelope
        @envelope ||= Envelope.new
      end

      # Should headers be a single hash or an array?
      def self.parse(parts)
        parts = parts.dup

        message = new
        message.envelope = Envelope.parse(parts)
        message.parts = parts
        message
      end

      def to_parts
        [
          *envelope.to_parts,
          *Array(parts).collect(&:to_s) # json?
        ]
      end
    end
  end
end
