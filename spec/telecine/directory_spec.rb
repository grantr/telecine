require 'spec_helper'

describe Telecine::Directory do
  it "stores node addresses" do
    Telecine::Directory["foobar"] = "tcp://localhost:1870"
    Telecine::Directory["foobar"].should == "tcp://localhost:1870"
  end
end
