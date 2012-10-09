require 'spec_helper'

describe Telecine::Registry::GossipAdapter do
  subject { Telecine::Registry::GossipAdapter.new :env => "test" }
  it_behaves_like "a Telecine registry"
end
