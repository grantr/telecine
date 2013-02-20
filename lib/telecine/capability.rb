require 'securerandom'
require 'openssl'
require 'red25519'
require 'hkdf'
require 'base32'

module Telecine
  # similar to the keyspace capability. Encodes an actor reference.
  #
  # actors can publish themselves as a specific actor or as a name or both. The default is both.
  #
  # actors that publish themselves have read/write capabilities. actors that can
  # call methods on published actors have r capabilities. actors that cannot call
  # methods or decrypt values but can verify authenticity have verify capabilities.
  #
  # read/write:
  # * can verify message authenticity.
  # * can encrypt and decrypt values.
  # * can generate capabilities for use by other nodes.
  # read:
  # * can verify message authenticity.
  # * can encrypt and decrypt values.
  # verify:
  # * can verify message authenticity.
  #
  #
  # caps include:
  # version number
  # encryption key (except verify caps)
  # signing or verify key
  # permissions (rw, r, v)
  # extra restrictions like parameter requirements. these will be signed and thus
  # double the size of the cap. essentially a cookie that is given back to the
  # dispatcher. these are not used to identify the actor and may be ignored by the
  # receiving dispatcher.
  # (Cannot be done without signing every cap)
  # (this can be added in a later version of caps)
  # Examples:
  # 1:rw:ac6b7a9c76b:a7c6b89769a87c6b986b986a
  # 1:r:ac6b7a9c76b:a7c6b89769a87c6b986b986a?arg1=blah:abc87b09c8a0b986cb06a08c6076c0ba6b
  #
  # nodes use these capabilities as reference ids when calling methods on remote
  # actors. There is no way to know the name of a remote actor without a capability.
  # Any node that can successfully reference an actor is considered to have access.
  # This relies on capabilities being unguessable and unforgeable.
  #
  # because a remote caller MUST have the capability to reference an actor,
  # encryption can be assumed.
  # even in the bootstrap case, the remote caller must have a capability
  # for the dispatcher as well, meaning that every communication with an actor
  # can be encrypted without needing a handshake process.
  #
  #
  # when a node receives a capability from a dispatcher (or reads it from config):
  #   1. it parses it from the token into a Capability object
  #   2. it uses that cap as the reference id for the actor (or actor name)
  #
  # when a dispatcher gets a new actor registered:
  #   1. It generates a readwrite cap for that actor
  #
  # when a dispatcher receives a request from a node for a reference to an actor:
  #   1. it looks up that actor in the registry
  #   2. it checks with the actor to see if the requester is authorized
  #   3. if yes, it returns a read cap generated from the earlier readwrite cap
  #
  # when a node wants to send a call/cast to a node:
  #   1. it uses the capability to encrypt message parts
  #   2. it signs the message using a key (TODO which key?)
  #
  # when a dispatcher receives a call/cast from a node:
  #   1. it looks up the actor corresponding to the given capability
  #   2. it ensures the message signature is accurate
  #   3. it decrypts the values
  #   4. it calls the method and gets the result
  #   5. it encrypts the result and sends it back
  #
  # when a node receives a reply from a node:
  #   1. it uses the capability to decrypt the result
  #     (This means the dispatcher must be the entity responsible for receiving replies, not the router)
  #
  # If all actors use capabilities as references, does a node need to use a verify key as id after all?
  # Probably not, but it's still useful to verify other messages like discovery and such.
  #
  #
    # capabilities must be node independent. it must be possible to distribute
    # capabilities to servers and clients without them being tied to server id.
  #
  # Something requires a capability we don't have
  class InvalidCapabilityError < StandardError; end

  # Potentially forged data: data does not match signature
  class InvalidSignatureError < StandardError; end

  # Capabilities provide access to encrypted data
  class Capability
    # Use AES256 with CBC padding
    SYMMETRIC_CIPHER = "aes-256-cbc"

    # Size of the symmetric key used for encrypting contents
    SYMMETRIC_KEY_BYTES = 32

    attr_reader :signature_key, :verify_key, :encryption_key, :capabilities

    # Generate a new writecap.
    def self.generate
      signature_key = Ed25519::SigningKey.generate.to_bytes
      hkdf = HKDF.new SecureRandom.random_bytes(SYMMETRIC_KEY_BYTES)
      encryption_key = hkdf.next_bytes(SYMMETRIC_KEY_BYTES)

      new('rw', signature_key, encryption_key)
    end

    # Parse a capability token into a capability object
    def self.parse(capability_string)
      if capability_string =~ /(\w+)@(.*)/
        caps, keys = $1, Base32.decode($2.upcase)

        case caps
        when 'r', 'rw'
          encryption_key, signature_key = keys.unpack("a#{SYMMETRIC_KEY_BYTES}a*")
        when 'v'
          encryption_key, signature_key = nil, keys
        else
          raise ArgumentError, "invalid capability level: #{caps}"
        end

        new(caps, signature_key, encryption_key)
      else
        raise ArgumentError, "Invalid capability string"
      end
    end

    def initialize(caps, signature_key, encryption_key = nil)
      @capabilities, @encryption_key = caps, encryption_key

      if caps.include?('w')
        @signature_key = Ed25519::SigningKey.new(signature_key)
        @verify_key = @signature_key.verify_key
      else
        @signature_key = nil
        @verify_key = Ed25519::VerifyKey.new(signature_key)
      end
    end

    # Encrypt a string
    def encrypt(string)
      raise InvalidCapabilityError, "don't have write capability" unless @signature_key

      cipher = OpenSSL::Cipher::Cipher.new(SYMMETRIC_CIPHER)
      cipher.encrypt

      cipher.key = encryption_key
      cipher.iv  = iv = cipher.random_iv

      ciphertext =  cipher.update(string)
      ciphertext << cipher.final

      message   = [iv, ciphertext.size, ciphertext].pack("a16Na*")
      signature = @signature_key.sign(message)
      signature + message
    end

    # Determine if the given encrypted value is authentic
    def verify(encrypted_value)
      signature, message = encrypted_value.unpack("a#{Ed25519::SIGNATURE_BYTES}a*")
      @verify_key.verify(signature, message)
    end

    # Decrypt an encrypted value, checking its authenticity with the verify key
    def decrypt(encrypted_value)
      raise InvalidCapabilityError, "don't have read capability" unless encryption_key
      raise InvalidSignatureError, "potentially forged data: signature mismatch" unless verify(encrypted_value)

      signature, message = encrypted_value.unpack("a#{Ed25519::SIGNATURE_BYTES}a*")
      iv, message_size, ciphertext = message.unpack("a16Na*")

      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.decrypt

      cipher.key = encryption_key
      cipher.iv  = iv

      plaintext = cipher.update(ciphertext)
      plaintext << cipher.final
      plaintext
    end

    # Degrade this capability to a lower level
    def degrade(new_capability)
      case new_capability
      when :r, :read, :readcap
        raise InvalidCapabilityError, "don't have read capability" unless @encryption_key
        self.class.new('r', @verify_key.to_bytes, @encryption_key)
      when :v, :verify, :verifycap
        self.class.new('v', @verify_key.to_bytes)
      else raise ArgumentError, "invalid capability: #{new_capability}"
      end
    end

    # Is this a write capability?
    def writecap?
      @capabilities.include?('w')
    end

    # Is this a read capability?
    def readcap?
      @capabilities.include?('r')
    end

    # Is this a verify capability?
    def verifycap?
      readcap? || @capabilities.include?('v')
    end

    # Generate a token out of this capability
    def to_s
      keys = encryption_key || ""

      if @signature_key
        keys += @signature_key.to_bytes
      else
        keys += @verify_key.to_bytes
      end

      keys32 = Base32.encode(keys).downcase.sub(/=+$/, '')
      "#{capabilities || 'v'}@#{keys32}"
    end

    def inspect
      "#<#{self.class} #{to_s}>"
    end
  end
end
