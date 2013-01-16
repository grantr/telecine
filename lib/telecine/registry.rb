module Telecine
  class Registry < Hash
    attr_accessor :_id

    def initialize(id=nil)
      @_lock = Mutex.new
      @_id = id || Celluloid::UUID.generate
    end

    def get(key)
      return if key.nil?
      @_lock.synchronize do
        fetch(key.to_sym, nil)
      end
    end

    def set(key, value)
      raise "Cannot store value with nil key" if key.nil?
      @_lock.synchronize do
        publish_update(key.to_sym, fetch(key.to_sym, nil), value)
        store(key.to_sym, value)
      end
    end

    def remove(key)
      raise "Cannot remove nil key" if key.nil?
      @_lock.synchronize do
        if deleted = delete(key.to_sym)
          Celluloid::Notifications.notifier.async.publish("#{_topic}.#{key.to_sym}.remove", @_id, key.to_sym, :remove, deleted, nil)
        end
      end
    end

    private :fetch, :store, :delete

    def publish_update(key, previous, current)
      if previous.is_a?(Array) && current.is_a?(Array)
        publish_array_update(key, previous, current)
      else
        Logger.debug "publish set #{_topic}.#{key}.set"
        Celluloid::Notifications.notifier.async.publish("#{_topic}.#{key}.set", @_id, key, :set, previous, current)
      end
    end

    def publish_array_update(key, previous, current)
      (previous - current).each do |removed|
        Celluloid::Notifications.notifier.async.publish("#{_topic}.#{key}.remove_element", @_id, key, :remove_element, removed, nil)
      end
      (current - previous).each do |added|
        Celluloid::Notifications.notifier.async.publish("#{_topic}.#{key}.add_element", @_id, key, :add_element, nil, added)
      end
    end

    def _topic
      "telecine.registry.#{@_id}"
    end
  end
end

require 'telecine/registry/callbacks'
