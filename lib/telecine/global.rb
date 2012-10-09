module Telecine
  # Global object registry shared among all Telecine nodes
  module Global
    extend self

    # Get a global value
    def get(key)
      Telecine.registry.get_global key.to_s
    end
    alias_method :[], :get

    # Set a global value
    def set(key, value)
      Telecine.registry.set_global key.to_s, value
    end
    alias_method :[]=, :set

    # Get the keys for all the globals in the system
    def keys
      Telecine.registry.global_keys.map(&:to_sym)
    end
  end
end
