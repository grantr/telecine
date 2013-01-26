require 'spec_helper'

describe Telecine::Stethoscope do
  include TerminateAll
  let(:fanout_notifier) { Celluloid::Notifications.notifier }
  
  it 'should set default notifier' do
    Telecine::Stethoscope.config.notifier.should == :remote_notifier
  end

  it 'should set default topic' do
    Telecine::Heart.topic.should == "telecine.heartbeat"
  end

  it 'should allow notifier override' do
    Telecine::Stethoscope.config.notifier = fanout_notifier.name
    Telecine::Stethoscope.config.notifier.should == fanout_notifier.name
  end

  it 'should get the notifier actor in instances' do
    Telecine::Stethoscope.config.notifier = fanout_notifier.name
    Telecine::Stethoscope.config.notifier.should == fanout_notifier.name
    subject.notifier.should be(fanout_notifier)
  end

  it 'should set notifier to an actor' do
    Telecine::Stethoscope.notifier = fanout_notifier
    Telecine::Stethoscope.notifier.should be(fanout_notifier)
    subject.notifier.should be(fanout_notifier)
  end
  
  it 'should be linked to notifier' do
    subject.links.should include(subject.notifier)
  end

  it 'should create nodes on heartbeats and beat their hearts' do
    terminate_all(described_class) # can only have one stethoscope running
    Telecine::Stethoscope.notifier = fanout_notifier
    @subject = described_class.new
    @subject.notifier.should be(fanout_notifier)

    Telecine::Node.registry.should be_empty

    fanout_notifier.publish("telecine.heartbeat", "1", "example.com", 1)
    sleep Celluloid::TIMER_QUANTUM

    Telecine::Node.registry.should_not be_empty
    key, node = Telecine::Node.registry.first
    key.to_s.should == "1"
    node.should be_a(Telecine::Node)
    node.id.should == "1"
    node.address.should == "example.com"

    node.fd.should_not be_empty
  end
end
