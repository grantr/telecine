Time.class_eval do
  include Telecine::Serializable

  def as_primitive(options={})
    xmlschema(6)
  end

  def self.from_primitive(representation, options={})
    parse(representation)
  end
end
