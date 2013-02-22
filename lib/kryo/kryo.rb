require 'json'
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

  def dump(object, io=nil)
    can = Can.new(self)
    can.add(object)
    JSON.dump(can.dump)
  end

  def load(string)
    segments = JSON.parse(string)
    can = Can.new(self, segments)
    can.load
  end
end

class Can
  attr_accessor :kryo
  attr_accessor :segments

  def initialize(kryo, segments=[])
    @kryo = kryo
    @segments = segments
    @ids = Hash.new { |h, k| h[k] = 0 }
  end

  def add(object)
    if serializer = @kryo.serializers[object.class]
      segment = Hash.new { |h, k| h[k] = {} }
      class_id = @kryo.class_to_id[object.class]
      id = @ids[class_id] += 1
      segment[class_id][id] = serializer.dump(self, object)
      @segments << segment

      [class_id, id]
    end
  end

  def dump
    segments
  end

  def load
    @objects = Hash.new { |h, k| h[k] = {} }
    segments = @segments.dup
    # final_segment = segments.pop
    segments.each do |segment|
      segment.each do |class_id, objects|
        serializer = @kryo.serializers[@kryo.id_to_class[class_id]]
        objects.each do |object_id, object|
          @objects[class_id][object_id] = serializer.load(self, object)
        end
      end
    end

    # final_segment
    @objects
  end

  def find(class_id, object_id)
    @objects[class_id.to_s][object_id.to_s]
  end
end
