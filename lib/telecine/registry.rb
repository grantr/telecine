module Telecine
  class Registry < Hash
    attr_accessor :_id

    # Should wrap a hash instead of inheriting from Hash
    def initialize(*args)
      super
      @_lock = Mutex.new
      @_id = Celluloid::UUID.generate
    end

    # can pass a block to automically set the key if unset
    def get(key, &block)
      return if key.nil?
      @_lock.synchronize do
        if !has_key?(key.to_sym) && block_given?
          value = yield
          _publish(key.to_sym, :set, nil, value)
          store(key.to_sym, value)
        else
          self[key.to_sym]
        end
      end
    end

    def set(key, value)
      raise "Cannot store value with nil key" if key.nil?
      @_lock.synchronize do
        _publish(key.to_sym, :set, self[key.to_sym], value)
        store(key.to_sym, value)
      end
    end

    def remove(key)
      raise "Cannot remove nil key" if key.nil?
      @_lock.synchronize do
        if deleted = delete(key.to_sym)
          _publish(key.to_sym, :remove, deleted, nil)
        end
      end
    end

    private :fetch, :store, :delete, :[], :[]=

    def _publish(key, action, previous, current)
      case action
      when :set
        if previous.is_a?(Array) && current.is_a?(Array)
          (previous - current).each do |removed|
            _publish(key, :remove_element, removed, nil)
          end
          (current - previous).each do |added|
            _publish(key, :add_element, nil, added)
          end
          return
        end
      when :remove
      when :add_element
      when :remove_element
      end
      Celluloid::Notifications.notifier.async.publish("#{_topic}.#{key}.#{action}", @_id, key, action, previous, current)
    end

    def _topic
      "telecine.registry.#{@_id}"
    end
  end
end

require 'telecine/registry/callbacks'
