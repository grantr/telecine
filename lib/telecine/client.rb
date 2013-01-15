require 'telecine/stethoscope'

module Telecine

  module Client
    class App < Celluloid::SupervisionGroup
      supervise Stethoscope, as: :stethoscope
    end
  end
end
