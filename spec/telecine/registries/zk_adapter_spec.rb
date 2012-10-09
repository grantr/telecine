# The Zookeeper CRuby dependency is pretty annoying :(
# Disabling until this can be spun off into a separate gem
=begin
require 'spec_helper'
require 'telecine/registries/zk_adapter'

describe Telecine::Registry::ZkAdapter do
  subject { Telecine::Registry::ZkAdapter.new :server => 'localhost', :env => 'test' }
  it_behaves_like "a Telecine registry"
end
=end