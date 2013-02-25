class Kryo
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

  def dump(object)
    can = Can.new(self)
    can.add(object)
    can
  end

  def load(segments)
    can = Can.new(self, segments)
    can.load
  end
end

class Can
  attr_accessor :kryo

  def initialize(kryo, objects={})
    @kryo = kryo
    @objects = objects
    @counter = 0
  end

  def add(*objects)
    object = objects.first
    # objects.collect do |object|
      if serializer = @kryo.serializer_for(object.class)
        id = (@counter += 1)
        class_id = @kryo.id_for(object.class)
        @objects[id] = { class_id => serializer.dump(self, object) }
        id
      else
        #TODO what if there is no serializer? maybe a default
      end
    # end
  end

  def dump
    @objects
  end

  def load
    objects = @objects.dup
    objects.inject do |accum, (object_id, thing)|
      class_id, object = thing.first

      @objects[object_id.to_s] = @kryo.serializer_for(class_id).load(self, object) #TODO should to_s be needed here?
    end
  end

  def find(id)
    @objects[id.to_s] #TODO should to_s be needed here?
  end
end
