Telecine.node.signing_key = "73c24ed4d6bab71537dc0a85ee339be1d861e7224e2b112895c17dc2905fb3ac"

Telecine::Notifier.configure do |n|
  c.endpoint = "tcp://127.0.0.1:58000"
end

Telecine::Router.config.endpoint = "tcp://127.0.0.1:48000"
