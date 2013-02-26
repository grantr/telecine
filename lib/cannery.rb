class Cannery
  # This class is the container for serializers. It stores the mapping between
  # classes and serializers, and classes and ids.
  
  # Maps classes to serializers.
  attr_accessor :serializers
  
  # Map class ids to classes and back again. Class ids are the class name by
  # default.
  attr_accessor :id_to_class, :class_to_id

  def initialize
    @serializers = {}
    @id_to_class = {}
    @class_to_id = {}
  end

  # Register a serializer for a class with an optional class id. The serializer
  # should be an instance of a serializer, not a serializer class. The class id
  # defaults to the class name if not present.
  #
  # Examples:
  #
  # register(String, IdentitySerializer.new)
  # register(MyObject, MyObjectSerializer.new, 2)
  #
  # Returns the assigned class id.
  def register(klass, serializer, id=nil)
    @serializers[klass] = serializer
    @id_to_class[id || klass.name] = klass
    @class_to_id[klass] = id || klass.name
  end

  # Can an object.
  # To can an object is to flatten the object graph and translate each object
  # into primitives that can be used to deserialize the object on the other end.
  # @see Can
  #
  # Returns the canned object suitable for serializing with any serialization library.
  # Raises UnserializableObject if an object is canned without a matching
  # serializer for its class.
  def can(object)
    can = Can.new(self)
    can.add(object)
    can.dump
  end

  # Uncan an object. The object must have been previously canned by a Cannery.
  #
  # Returns the uncanned object.
  # Raises UnserializableObject if an object is uncanned without a matching
  # serializer for its class.
  def uncan(primitive)
    can = Can.new(self, primitive)
    can.load
  end

  # Retrieve the serializer for a class or class id.
  #
  # Returns the serializer or nil if no serializer was found.
  def serializer_for(class_or_id)
    if class_or_id.is_a?(Class)
      @serializers[class_or_id]
    else
      @serializers[@id_to_class[class_or_id]]
    end
  end

  # Retrieve the class id for a given class.
  #
  # Returns the class id or nil if no class id was found.
  def id_for(klass)
    @class_to_id[klass]
  end

  # Dup the serializer and class id hashes on copy so that the copied object
  # will get its own hashes.
  def initialize_copy(other)
    @serializers = @serializers.dup
    @id_to_class = @id_to_class.dup
    @class_to_id = @class_to_id.dup
  end

  # Raised when an object in a Can has no corresponding serializer.
  class UnserializableObject < StandardError; end

  class Can
    attr_accessor :cannery

    def initialize(cannery, primitive={})
      @cannery = cannery
      @primitive = primitive
      @counter = 0
    end

    # Add an object to the can. The object is assigned an id, serialized,
    # and added to the can hash.
    #
    # Returns the object id.
    # Raises UnserializableObject if no serializer can be found for an object.
    def add(object)
      id = (@counter += 1)
      class_id = @cannery.id_for(object.class)
      if serializer = @cannery.serializer_for(class_id)
        @primitive[id] = { class_id => serializer.dump(self, object) }
        id
      else
        raise UnserializableObject, "#{object.class} cannot be serialized. Did you register a serializer for it?"
      end
    end

    # dump the Can.
    # Returns a hash suitable for serializing with any serialization library.
    def dump
      @primitive
    end

    # Load the object from the primitive in the Can.
    #
    # Returns the uncanned object.
    # Raises UnserializableObject if no serializer can be found for an object.
    def load
      @objects = {}
      @primitive.inject(nil) do |accum, (object_id, thing)|
        class_id, object = thing.first
        if serializer = @cannery.serializer_for(class_id)
          @objects[object_id.to_s] = serializer.load(self, object) #TODO should to_s be needed here?
        else
          raise UnserializableObject, "#{object.class} cannot be serialized. Did you register a serializer for it?"
        end
      end
    end

    # Find an object in the can by id.
    # This will be called by serializers looking for objects by reference.
    #
    # Returns the object or nil if not found.
    def find(id)
      @objects[id.to_s] #TODO should to_s be needed here?
    end
  end
end
