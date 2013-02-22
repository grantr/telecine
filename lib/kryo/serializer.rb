require 'time'
class TimeSerializer

  def dump(can, time)
    time.xmlschema(6)
  end

  def load(can, string)
    Time.parse(string)
  end
end

require 'celluloid'

class MailboxSerializer

  def initialize(node)
    @node = node
  end

  def dump(can, mailbox)
    "#{mailbox.address}@#{@node}"
  end

  def load(can, object)
    Celluloid::Mailbox.new
  end
    
    
end

class SyncCallSerializer

  def dump(can, call)
    id = can.add call.caller
    [id, call.method.to_s, call.arguments]
  end

  def load(can, object)
    mailbox_id, method, arguments = object
    caller = can.find(*mailbox_id)
    Celluloid::SyncCall.new(caller, method, arguments)
  end
end
