require 'spec_helper'

describe Telecine::Registry::RedisAdapter do
  subject { Telecine::Registry::RedisAdapter.new :env => 'test' }
  it_behaves_like "a Telecine registry"
end