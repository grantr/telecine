require 'spec_helper'

describe Telecine::Registry do
  it_should_behave_like "a Registry"

  it 'should not respond to hash methods' do
    [:fetch, :store, :delete, :[], :[]=].each do |method|
      subject.respond_to?(method).should be_false
    end
  end
end
