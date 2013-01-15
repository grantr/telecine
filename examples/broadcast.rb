require 'telecine'
Telecine::Server::App.run!
Telecine::Client::App.run!

require './examples/config'
# Telecine.config.broadcast_endpoint = "tcp://127.0.0.1:58000"
# 
# Telecine.config.servers = ["tcp://127.0.0.1:58000"]

require File.expand_path('../broadcaster', __FILE__)
require File.expand_path('../subscriber', __FILE__)

b = Broadcaster.new
s = Subscriber.new

b.broadcast("topic", "hello")
sleep 5
