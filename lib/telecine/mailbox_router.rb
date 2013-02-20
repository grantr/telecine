module Telecine
  # The MailboxRouter should:
  #   - wrap a Referenceable mailbox
  #   - track calls and responses
  class MailboxRouter
    attr_accessor :stack
    attr_accessor :mailbox

    def initialize(mailbox)
      @mailbox = mailbox
    end

    def address
      mailbox.address
    end

    def <<(message)
      puts "got an incoming message: #{message}"
      @mailbox << message.payload
    end

  end
end
