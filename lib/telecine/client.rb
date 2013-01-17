require 'telecine/stethoscope'

module Telecine
  class Client < Celluloid::SupervisionGroup
    supervise Stethoscope, as: :stethoscope
  end
end
