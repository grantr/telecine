require 'spec_helper'

describe Telecine::Registry::MonetaAdapter do
  subject { Telecine::Registry::MonetaAdapter.new :env => "test" }
  it_behaves_like "a Telecine registry"
end
