Celluloid::ZMQ.init

Celluloid.logger = Celluloid::IncidentLogger.new
Celluloid::IncidentReporter.supervise_as :default_incident_reporter, STDERR
Celluloid::EventReporter.supervise_as :default_event_reporter, STDOUT