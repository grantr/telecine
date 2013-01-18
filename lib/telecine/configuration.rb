module Telecine
  class Configuration < Registry
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

  end
end

require 'telecine/configuration/configurable'
