Celluloid::ZMQ.init

Celluloid.logger = Celluloid::IncidentLogger.new
# Celluloid::IncidentReporter.supervise_as :default_incident_reporter, STDERR
Celluloid::EventReporter.supervise_as :default_event_reporter, STDOUT

#TODO these should not be started automatically as some apps might not need them
# or might use different implementations. In fact everything in this file should
# be optional.
Telecine::Notifier.supervise_as :remote_notifier
Telecine::Router.supervise_as :router
Telecine::Dispatcher.supervise_as :dispatcher
