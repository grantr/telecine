require 'spec_helper'

describe Telecine::Global do
  it "can handle unexisting keys" do
    expect { Telecine::Global[:unexisting] }.to_not raise_exception
  end

  it "stores values" do
    Telecine::Global[:the_answer] = 42
    Telecine::Global[:the_answer].should == 42

    # Double check the global value is available on all nodes
    node = Telecine::Node['test_node']
    20.downto(0) do |i|
      break if node[:test_actor].the_answer
      sleep 1
    end
    node[:test_actor].the_answer.should == 42
  end

  it "stores the keys of all globals" do
    Telecine::Global[:foo] = 1
    Telecine::Global[:bar] = 2
    Telecine::Global[:baz] = 3

    keys = Telecine::Global.keys
    [:foo, :bar, :baz].each { |key| keys.should include key }
  end
end
