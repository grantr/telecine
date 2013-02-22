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
  attr_accessor :segments

  def initialize(kryo, segments=[])
    @kryo = kryo
    @segments = segments
    @counter = 0
  end

  def add(*objects)
    #segment = Segment.new
    segment = Hash.new { |h, k| h[k] = {} } # gotta dump the procs

    object = objects.first
    # objects.collect do |object|
      if serializer = @kryo.serializer_for(object.class)
        id = (@counter += 1)
        class_id = @kryo.id_for(object.class)
        segment[class_id][id] = serializer.dump(self, object)
        # segment.add(id, serializer.dump(self, object))

        @segments << segment
        id
      else
        #TODO what if there is no serializer? maybe a default
      end
    # end
  end

  def dump
    segments
  end

  def load
    @objects = {}
    segments = @segments.dup
    # final_segment = segments.pop
    #
    # this should be in the segment class
    segments.each do |segment|
      segment.each do |class_id, objects|
        serializer = @kryo.serializer_for(class_id)
        objects.each do |object_id, object|
          @objects[object_id.to_s] = serializer.load(self, object) #TODO should to_s be needed here?
        end
      end
    end

    # final_segment
    @objects
  end

  def find(id)
    @objects[id.to_s] #TODO should to_s be needed here?
  end
end
