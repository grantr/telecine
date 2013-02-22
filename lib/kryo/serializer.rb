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
    mailbox_id = can.add call.caller
    # This should be something like "i wish to serialize this object or objects"
    # the can returns either the object or (if there is a serializer registered) an id
    # but then how does it know its an id? and how does the deserializer know?
    # arg_ids = can.add call.arguments
    # [mailbox_id, call.method.to_s, arg_ids]
    [mailbox_id, call.method.to_s, call.arguments]
  end

  def load(can, object)
    # mailbox_id, method, arg_ids = object
    mailbox_id, method, args = object
    puts "looking for mailbox #{mailbox_id.inspect}"
    mailbox = can.find(mailbox_id)
    puts "found mailbox #{mailbox}"
    # args = arg_ids.collect { |id| can.find(*id) }
    Celluloid::SyncCall.new(mailbox, method, args)
  end
end
