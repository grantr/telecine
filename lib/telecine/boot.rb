#TODO start this when necessary. Some apps might not use zmq at all.
Celluloid::ZMQ.init

  #TODO allow the user to choose what logging tech they want
Celluloid.logger = Celluloid::IncidentLogger.new
# Celluloid::IncidentReporter.supervise_as :default_incident_reporter, STDERR
Celluloid::EventReporter.supervise_as :default_event_reporter, STDOUT

#TODO these should not be started automatically as some apps might not need them
# or might use different implementations.
# TODO Would be nice to have a dependency mechanism. Some way for actors to declare
# that they depend on certain functionality that other actors provide.
Telecine::Notifier.supervise_as :remote_notifier
Telecine::Router.supervise_as :router
Telecine::Dispatcher.supervise_as :dispatcher
