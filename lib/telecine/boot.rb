Celluloid::ZMQ.init

Celluloid.logger = Celluloid::IncidentLogger.new
# Celluloid::IncidentReporter.supervise_as :default_incident_reporter, STDERR
Celluloid::EventReporter.supervise_as :default_event_reporter, STDOUT

#TODO should these be started automatically?
Telecine::Notifier.supervise_as :remote_notifier
Telecine::Router.supervise_as :router
Telecine::Dispatcher.supervise_as :dispatcher
