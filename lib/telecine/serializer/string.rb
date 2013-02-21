# Experimental string serialization that adds an encoding
String.class_eval do
  include Telecine::Serializable

  def as_primitive(options={})
    [encoding.name, self.dup.force_encoding(Encoding.default_external)]
  end

  def self.from_primitive(primitive, options={})
    encoding, string = primitive
    string.force_encoding(encoding)
  end
end
