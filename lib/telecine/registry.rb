module Telecine
  class Registry
    include Enumerable
    extend Forwardable

    attr_accessor :_id

    def_delegators :to_hash, :has_key?, :size, :each

    # Should wrap a hash instead of inheriting from Hash
    def initialize(*args, &block)
      @_store = Hash.new(*args, &block)
      @_lock = Mutex.new
      @_id = Celluloid::UUID.generate
    end

    # can pass a block to automically set the key if unset
    def get(key, &block)
      return if key.nil?
      key = key.to_s
      @_lock.synchronize do
        if !@_store.has_key?(key) && block_given?
          value = yield
          _publish(key, :set, nil, value)
          @_store.store(key, value)
        else
          @_store[key]
        end
      end
    end

    def set(key, value)
      raise "Cannot store value with nil key" if key.nil?
      key = key.to_s
      @_lock.synchronize do
        _publish(key, :set, @_store[key], value)
        @_store.store(key, value)
      end
    end

    def remove(key)
      raise "Cannot remove nil key" if key.nil?
      key = key.to_s
      @_lock.synchronize do
        if deleted = @_store.delete(key)
          _publish(key, :remove, deleted, nil)
        end
      end
    end

    def to_hash
      @_lock.synchronize { @_store.dup }
    end

    def merge!(other)
      @_lock.synchronize do
        other.each do |key, value|
          key = key.to_s
          unless @_store[key] == value
            _publish(key, :set, @_store[key], value)
            @_store.store(key, value)
          end
        end
      end
    end

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
