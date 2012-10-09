module Telecine
  # Directory of nodes connected to the Telecine cluster
  module Directory
    extend self

    @@directory = {}
    @@directory_lock = Mutex.new

    # Get the URL for a particular Node ID
    def get(node_id)
      @@directory_lock.synchronize do
        @@directory[node_id]
      end
    end
    alias_method :[], :get

    # Set the address of a particular Node ID
    def set(node_id, addr)
      @@directory_lock.synchronize do
        @@directory[node_id] = addr
      end
    end
    alias_method :[]=, :set

    # List all of the node IDs in the directory
    def all
      @@directory_lock.synchronize { @@directory.keys }
    end

    # Clear the directory.
    def clear
      @@directory_lock.synchronize { @@directory.clear }
    end
  end
end
