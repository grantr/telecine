module Telecine
  module Callbacks
    def self.included(base)
      base.extend(ClassMethods)
    end

    def callbacks
      @callbacks ||= Hash.new { |h, k| h[k] = [] }
    end

    def set_callback(type, name, method=nil, &block)
      if method
        callbacks_for(type, name) << method
      else
        callbacks_for(type, name) << block
      end
      self
    end

    def callbacks_for(type, name)
      callbacks[callback_key(type, name)]
    end
    
    def callback_key(type, name)
      [type.to_sym, name.to_sym]
    end

    def run_callbacks(name, *args)
      modified = callbacks_for(:before, name).inject(args) do |memo, cb|
        [cb.call(*memo)]
      end
      yield(*modified) if block_given?
      callbacks_for(:after, name).each {|cb| cb.call(*args)}
    end

    module ClassMethods
      def define_callbacks(name, *types)
        types.each do |type|
          callback_name = "#{type}_#{name.to_s}"
          define_method callback_name do |&blk|
            set_callback(type, name, &blk)
          end
        end
      end
    end
  end
end
