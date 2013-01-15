require 'telecine/heart'

module Telecine
  module Server
    class App < Celluloid::SupervisionGroup
      supervise Heart, as: :heart
    end
  end
end
