require 'json'

module Telecine
  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
      Serializer.registry[base.name] = base
    end

    module ClassMethods
      def from_primitive(primitive, options={})
        primitive
      end
    end

    def as_primitive(options={})
      self
    end
  end

  class Serializer
    def self.registry
      @registry ||= {}
    end

    def self.backends
      @backends ||= {}
    end

    attr_accessor :backend, :options

    # default backend is JSON
    # other backend options include MultiJson, MessagePack, or Marshal
    # using Marshal can get you free instantiation but is not secure
    def initialize(*args)
      @options = args.last.is_a?(Hash) ? args.pop : {}
      backend = args.first
      @backend = self.class.backends[backend] || backend || JSON
    end

    def load(bytes)
      representation = backend.load(bytes)
      objects = representation.collect do |name, primitive|
        if self.class.registry.has_key?(name)
          self.class.registry[name].from_primitive(primitive, options)
        else
          primitive
        end
      end
      objects.first
    end

    def dump(object)
      if object.respond_to?(:as_primitive)
        #TODO allow class to change its registered name
        backend.dump(object.class.name => object.as_primitive(options))
      else
        backend.dump(object.class.name => object)
      end
    end
  end
end

require 'telecine/serializer/time'
