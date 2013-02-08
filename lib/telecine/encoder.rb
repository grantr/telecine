require 'telecine/message'

module Telecine
  module Encoder

    # takes parts, returns encoded parts
    def encode(*parts)
      raise NotImplementedError, "encode not implemented"
    end

    # takes encoded parts, returns decoded parts
    def decode(*parts)
      raise NotImplementedError, "decode not implemented"
    end
  end

  class IdentityEncoder
    include Encoder
    def encode(*parts)
      parts
    end

    def decode(*parts)
      parts
    end
  end
end
