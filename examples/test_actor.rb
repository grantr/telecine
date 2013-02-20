class TestActor
  include Celluloid
  include Telecine::Referenceable

  def speak(n)
    puts "speaking : #{n}"
    "spoken to #{n}"
  end

  def run
    loop do
      message = receive { |msg| msg.is_a?(Message) }

      Logger.debug("received message in test actor: #{message.inspect}")
    end
  end
end
