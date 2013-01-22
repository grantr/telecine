require 'telecine'
Telecine::Client.run!

require './examples/client-config'

sleep 5
node = Telecine::Node.registry.first.last
ref = node.reference_to(:test_actor)
puts ref.call(:speak, "hello")
