require 'moneta'
require 'moneta/memory'

module Telecine
  module Registry
    class MonetaAdapter
      def initialize(options)
        # Convert all options to symbols :/
        options = options.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }

        @env = options[:env] || 'production'
        @namespace = options[:namespace] || "telecine_#{@env}"

        # We might want to use something like a TieredCache later..
        # Memory + BasicFile..
        # @moneta = Moneta::TieredCache.new options
        @moneta = Moneta::Memory.new options

        @global_registry = Registry.new(@moneta, :globals)
      end

      class Registry
        def initialize(moneta, name)
          @name = name
          @moneta = moneta
        end

        def get(key)
          @moneta[@name][key.to_s]
        end

        def set(key, value)
          @moneta[@name][key.to_s] = value
        end

        def all
          @moneta[@name].keys
        end

        # Telecine registry behaviors
        alias_method :global_keys, :all

        def clear
          @moneta.delete(@name)
        end
      end

      def get_global(key);        @global_registry.get(key) end
      def set_global(key, value); @global_registry.set(key, value) end
      def global_keys;            @global_registry.global_keys end
      def clear_globals;          @global_registry.clear end
    end
  end
end
