require 'json'

module Telecine
  # Include Telecine::Serializable module in classes that need custom
  # serialization. The class will be serialized with a type annotation
  # so that it can be unserialized correctly on the other end.
  #
  # The class should implement from_primitive and as_primitive.
  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
      Serializer.registry[base.name] = base
    end

    module ClassMethods
      # This should be implemented by the including class. It takes a primitive
      # value (hash, array, string, etc) and returns an unserialized object.
      #
      # The default implementation returns the primitive given.
      def from_primitive(primitive, options={})
        primitive
      end
    end

    # This should be implemented by the including class. It returns a primitive
    # value (hash, array, string, etc) representing self. Type annotation is added
    # by the serializer, so this method does not need to annotate its own class
    # unless it has special needs.
    #
    # The default implementation returns self.
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
