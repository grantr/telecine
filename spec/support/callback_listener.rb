class CallbackListener
  include Celluloid
  include Telecine::Registry::Callbacks

  attr_accessor :callback_args
end
