require 'telecine/local_node'

module Telecine
  # like a normal registry, but always has a local node with the local id
  class NodeRegistry < Registry
    def get(key)
      @_lock.synchronize do
        if key == Telecine.node.id || key == :_local
          # note that this is not published, only available when requested
          fetch(key.to_sym, nil) || store(key.to_sym, LocalNode.new)
        else
          fetch(key.to_sym, nil)
        end
      end
    end

    def local
      get(:_local)
    end
  end
end
