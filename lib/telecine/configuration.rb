require 'weakref'

module Telecine
  class Configuration < Registry

    def initialize(parent=nil)
      if parent
        parent._children << WeakRef.new(self)
        super() { |h, k| parent.get(k) }
      else
        super()
      end
    end

    def inheritable_copy
      self.class.new(self)
    end

    def _children
      @_children ||= []
    end

    def method_missing(name, *args)
      if name.to_s =~ /(.*)=$/
        set($1, args.first)
      else
        get(name.to_sym)
      end
    end

    def respond_to?(name)
      true
    end

    def compile_methods!
      @_lock.synchronize do
        self.class.compile_methods!(keys)
      end
    end

    # compiles reader methods so we don't have to go through method_missing
    def self.compile_methods!(keys)
      keys.compact.reject { |m| method_defined?(m) }.each do |key|
        # only compile keys that are valid methods
        # this rejects a few technically valid methods, but that's probably ok
        # to allow ALL valid methods, use key.inspect !~ /[@$"]/
        # Symbol will quote identifiers that are not valid (plus instance and global vars)
        if key =~ /^[A-Za-z]\w*$/
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{key}; get(:'#{key}'); end
          RUBY
        end
      end
      #TODO writer methods
    end

    def _publish(key, action, previous, current)
      super
      _children.each do |child|
        child._publish(key, action, previous, current) if child.weakref_alive? && !child.has_key?(key)
      end
      _children.reject! { |child| !child.weakref_alive? }
    end
  end
end

require 'telecine/configuration/configurable'
