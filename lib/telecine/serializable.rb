module Telecine
  module Serializable
    def self.included(base)
      base.extend(ClassMethods)
      registry[base.name] = base
    end

    def self.registry
      @registry ||= {}
    end

    module ClassMethods
      def tc_load(representation, options={})
        representation
      end
    end

    def tc_dump(options={})
      self
    end
  end
end

require 'time'
class Time
  include Telecine::Serializable

  def tc_dump(options={})
    iso8601
  end

  def self.tc_load(representation, options={})
    parse(representation)
  end
end
