module Telecine
  module Configurable

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def config
        # create a new "anonymous" class that will host the compiled reader methods
        @_config ||= Class.new(Configuration).new
      end

      def configure
        yield config
      end

      # TODO deferred default support would be nice
      # would also solve the problem of needing the whole infrastructure to be up
      # when classes are required
      def config_accessor(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          reader, line = "def #{name}; config.get(:'#{name}'); end", __LINE__
          writer, line = "def #{name}=(value); config.set(:'#{name}', value); end", __LINE__

          singleton_class.class_eval reader, __FILE__, line
          singleton_class.class_eval writer, __FILE__, line
          class_eval reader, __FILE__, line unless options[:instance_reader] == false
          class_eval writer, __FILE__, line unless options[:instance_writer] == false
        end
      end

      def actor_accessor(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}

        names.each do |name|
          reader, line = "def #{name}; actor = config.get(:'#{name}'); actor.is_a?(Symbol) ? Celluloid::Actor[actor] : actor; end", __LINE__
          writer, line = "def #{name}=(value); config.set(:'#{name}', value); end", __LINE__

          singleton_class.class_eval reader, __FILE__, line
          singleton_class.class_eval writer, __FILE__, line
          class_eval reader, __FILE__, line unless options[:instance_reader] == false
          class_eval writer, __FILE__, line unless options[:instance_writer] == false
        end
      end
    end

    def config
      @_config ||= self.class.config.inheritable_copy
    end
  end
end
