require 'telecine/heart'

module Telecine
  class Server < Celluloid::SupervisionGroup
    supervise Heart, as: :heart
  end
end
