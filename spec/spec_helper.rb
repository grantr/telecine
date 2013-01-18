require 'bundler/setup'

if ENV['COVERAGE'] == 'true' && RUBY_ENGINE == "ruby"
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'telecine'
require 'celluloid/rspec'

Celluloid::Actor[:default_event_reporter].terminate if Celluloid::Actor[:default_event_reporter]
Celluloid::Actor[:default_incident_reporter].terminate if Celluloid::Actor[:default_incident_reporter]

Dir['./spec/support/*.rb'].map {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
