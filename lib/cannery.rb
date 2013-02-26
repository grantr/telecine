class Cannery
  # This class is the container for serializers and state.
  attr_accessor :serializers, :id_to_class, :class_to_id

  def initialize
    @serializers = {}
    @id_to_class = {}
    @class_to_id = {}
  end

  def register(klass, serializer, id=nil)
    @serializers[klass] = serializer
    @id_to_class[id || klass.name] = klass
    @class_to_id[klass] = id || klass.name
  end

  def can(object)
    can = Can.new(self)
    can.add(object)
    can
  end

  def uncan(primitive)
    can = Can.new(self, primitive)
    can.load
  end

  # could maybe have a default serializer
  def serializer_for(class_or_id)
    if class_or_id.is_a?(Class)
      @serializers[class_or_id]
    else
      @serializers[@id_to_class[class_or_id]]
    end
  end

  def id_for(klass)
    @class_to_id[klass]
  end

  def initialize_copy(other)
    @serializers = @serializers.dup
    @id_to_class = @id_to_class.dup
    @class_to_id = @class_to_id.dup
  end

  class UnserializableObject < StandardError; end

  class Can
    attr_accessor :cannery

    def initialize(cannery, primitive={})
      @cannery = cannery
      @primitive = primitive
      @counter = 0
    end

    #TODO this should (optionally?) raise if something can't be serialized
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

    def dump
      @primitive
    end

    def load
      @objects = {}
      @primitive.inject(nil) do |accum, (object_id, thing)|
        class_id, object = thing.first
        @objects[object_id.to_s] = @cannery.serializer_for(class_id).load(self, object) #TODO should to_s be needed here?
      end
    end

    def find(id)
      @objects[id.to_s] #TODO should to_s be needed here?
    end
  end
end
