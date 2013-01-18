RSpec.configure do |config|
  # terminate actors created during tests
  config.before(:each) do
    @running_actors = Celluloid::Actor.all
  end

  config.after(:each) do
    new_actors = Celluloid::Actor.all - @running_actors
    new_actors.each { |a| a.terminate if a.alive? }
  end
end
