module Telecine
  module Broker

    #TODO is there any shared behavior?
    module Request

      def self.load(parts)
        raise NotImplementedError, "load is not implemented"
      end

      def dump
        raise NotImplementedError, "dump is not implemented"
      end

      # return a non-nil value from here and it will be returned as a reply
      def dispatch(mailbox)
        raise NotImplementedError, "dispatch is not implemented"
      end
    end

    #TODO what encodes/decodes these messages?
    # do these need to know what messages look like?
    # Are these classes the message encoding/decoding authorities? If so they should not be called handlers. they should be called Requests. Call, Cast are requests. Reply is probably not a request.
    # would be nice if these single classes were responsible for encoding and decoding, but then they need to know more about messages than might be desirable.
    #
    # what does a Request need on the sending end?
    # to_message
    # 
    # what does a Request need on the receiving end?
    # from_message
    # dispatch
    #
    # References create these classes when sending method calls.
    class Call
      include Request

      attr_accessor :destination, :method, :arguments

      def self.load(parts)
        @destination, @method, *@arguments = parts
      end

      def dump
        [@destination, @method, *@arguments]
      end

      def dispatch(mailbox)
        Celluloid::Actor.call(mailbox, method, *arguments)
      end
    end

    class Cast < Call
      def dispatch(mailbox)
        Celluloid::Actor.async(mailbox, method, *arguments)
        nil
      end
    end

    class Reply
      def self.load(parts)
        @result = parts
      end

      def dump
        [@result]
      end
    end
  end
end
