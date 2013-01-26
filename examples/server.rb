require 'telecine'
Telecine::Server.run!
require './examples/server-config'

require './examples/test_actor'

ta = TestActor.supervise_as :test_actor
Celluloid::Actor[:dispatcher].register(ta.actors.first, :test_actor)

Celluloid::Actor.join(Celluloid::Actor[:remote_notifier])
