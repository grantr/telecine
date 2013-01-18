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
end
