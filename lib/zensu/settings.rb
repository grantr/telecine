require 'hashie'
require 'multi_json'

module Zensu
  class Settings < Hashie::Mash
    def self.load(filename)
      new MultiJson.load(File.read(filename))
    end

    # TODO if there is no config, use default values.
    # it should work to install the gem and run the server and client without any other setup.
    # if redis is not configured, use a fakeredis persister. (with an appropriate warning against using this in production)

    def valid?
      #TODO validate required sections
      true
    end
    
    def ssl
      @ssl ||= SSL.new(self['ssl'])
    end

    class SSL < Hashie::Mash
      #TODO if relative paths join with top level config path
      #TODO should these raise on missing or return nil or empty string?
      def cert
        @cert ||= File.read(cert_file)
      end

      def cacert
        @cacert ||= File.read(cacert_file)
      end

      def key
        @key ||= File.read(key_file)
      end
    end

  end
end