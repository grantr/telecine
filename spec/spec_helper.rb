require 'rubygems'
require 'bundler'
Bundler.setup

require 'telecine'
Dir['./spec/support/*.rb'].map { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    Telecine.setup :directory => { :id => 'test_node', :addr => "tcp://127.0.0.1:#{TestNode::PORT}" }
    @supervisor = Telecine.run!

    TestNode.start
    TestNode.wait_until_ready
  end

  config.after(:suite) do
    TestNode.stop
  end
end

# FIXME: this is hax to bypass the other at_exit handlers
at_exit { exit! $!.status }