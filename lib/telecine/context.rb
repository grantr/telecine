module Telecine
  class Context
    include Configurable

    def brokers
      @brokers ||= Celluloid::Registry.new
    end

    def registry
      @registry ||= Celluloid::Registry.new
    end

    # declarative configuration
    #
    # new do
    #   broker InsecureBroker
    #   broker SecureBroker, as: :secure_broker
    # end
  end
end
