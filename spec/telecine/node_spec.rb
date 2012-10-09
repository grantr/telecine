require 'spec_helper'

describe Telecine::Node do
  before do
    @node = Telecine::Node['test_node']
    @node.id.should == 'test_node'
  end

  it "finds all available nodes" do
    nodes = Telecine::Node.all
    nodes.should include(Telecine.me)
  end

  it "finds remote actors" do
    actor = @node[:test_actor]
    actor.value.should == 42
  end

  it "lists remote actors" do
    @node.actors.should include :test_actor
    @node.all.should include :test_actor
  end
end
