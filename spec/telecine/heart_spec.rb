require 'spec_helper'

describe Telecine::Heart do
  include TerminateAll
  let(:fanout_notifier) { Celluloid::Notifications.notifier }
  
  it 'should set default notifier' do
    Telecine::Heart.notifier.should == :remote_notifier
  end

  it 'should allow notifier override' do
    Telecine::Heart.notifier = fanout_notifier.name
    Telecine::Heart.notifier.should == fanout_notifier.name
  end

  it 'should get the notifier actor in instances' do
    Telecine::Heart.notifier = fanout_notifier.name
    Telecine::Heart.notifier.should == fanout_notifier.name
    subject.notifier.should be(fanout_notifier)
  end

  it 'should set notifier to an actor' do
    Telecine::Heart.notifier = fanout_notifier
    Telecine::Heart.notifier.should be(fanout_notifier)
    subject.notifier.should be(fanout_notifier)
  end

  it 'should beat heart periodically' do
    terminate_all(described_class)
    subscriber = Subscriber.new
    subscriber.subscribe('telecine.heartbeat')
    @subject = described_class.new

    sleep Telecine::Heart::HEARTBEAT*2
    subscriber.events.size.should be_within(1).of(2)
  end

  it 'should send info in heartbeat' do
    terminate_all(described_class)
    subscriber = Subscriber.new
    subscriber.subscribe('telecine.heartbeat')
    @subject = described_class.new

    Telecine::Node.id = "1"
    Telecine::Router.endpoint = "example.com"

    @subject.beat
    node_id, router_endpoint, time = subscriber.events.first
    node_id.should == "1"
    router_endpoint.should == "example.com"
  end
end
