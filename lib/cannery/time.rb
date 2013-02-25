require 'time'

class TimeSerializer
  def initialize(precision=6)
    @precision = precision
  end

  def dump(can, time)
    time.xmlschema(precision)
  end

  def load(can, string)
    Time.parse(string)
  end
end
