require 'spec_helper'

describe Telecine::Configuration do
  it_should_behave_like "a Registry"

  it 'should respond to methods as keys' do
    subject.foo.should be_nil
    subject.set(:foo, :bar)
    subject.foo.should == :bar
  end

  it 'should respond to all methods' do
    subject.respond_to?(:foo).should be_true
  end

  it 'should compile methods to avoid method_missing' do
    subject.singleton_class.class_eval do
      undef :method_missing
    end

    subject.set(:foo, "bar")

    subject.compile_methods!
    expect { subject.foo }.to_not raise_error
    subject.foo.should == "bar"
  end

  it 'should take a parent in initialize' do
    child = described_class.new(subject)
    subject.set(:inherited, "parent")
    child.get(:inherited).should == "parent"
    child.set(:inherited, "child")
    child.get(:inherited).should == "child"
    subject.get(:inherited).should == "parent"
  end

  it 'should create a child copy' do
    child = subject.inheritable_copy
    subject.set(:inherited, "parent")
    child.get(:inherited).should == "parent"
    child.set(:inherited, "child")
    child.get(:inherited).should == "child"
    subject.get(:inherited).should == "parent"
  end

  context "child publishing" do
    it 'should maintain a list of children' do
      child = subject.inheritable_copy
      subject._children.should include(child)
    end

    it 'should publish to children' do
      child = subject.inheritable_copy
      subscriber = Subscriber.new
      subscriber.subscribe("#{child._topic}.foo.set")
      subject.set(:foo, "bar")
      sleep Celluloid::TIMER_QUANTUM
      subscriber.events.should_not be_empty
    end

    it 'should not publish to children that have the key' do
      child = subject.inheritable_copy
      child.set(:foo, "baz")
      subscriber = Subscriber.new
      subscriber.subscribe("#{child._topic}.foo.set")
      subject.set(:foo, "bar")
      sleep Celluloid::TIMER_QUANTUM
      subscriber.events.should be_empty
    end

    it 'should publish to children that removed their key' do
      child = subject.inheritable_copy
      child.set(:foo, "baz")
      child.remove(:foo)
      subscriber = Subscriber.new
      subscriber.subscribe("#{child._topic}.foo.set")
      subject.set(:foo, "bar")
      sleep Celluloid::TIMER_QUANTUM
      subscriber.events.should_not be_empty
    end

    it 'should prune children that go out of scope' do
      block = lambda do
        child = subject.inheritable_copy
        subject._children.should include(child)
      end
      subject.set(:foo, "bar") # must publish to prune
      subject._children.should be_empty
    end
  end
end
