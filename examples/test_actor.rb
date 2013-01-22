class TestActor
  include Celluloid

  def speak(n)
    puts "speaking : #{n}"
    "spoken to #{n}"
  end
end
