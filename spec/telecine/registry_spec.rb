require 'spec_helper'

describe Telecine::Registry do
  it_should_behave_like "a Registry"

  it 'should take hash default arg' do
    subject = described_class.new("foo")
    subject.get(:foo).should == "foo"
  end

  it 'should not respond to hash methods' do
    [:fetch, :store, :delete, :[], :[]=].each do |method|
      subject.respond_to?(method).should be_false
    end
  end
end
