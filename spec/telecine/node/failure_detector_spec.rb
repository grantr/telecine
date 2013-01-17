require 'spec_helper'

describe Telecine::Node::FailureDetector do
  it 'should have a low phi value after only a second' do
    time = 0
    0.upto(100) do |i|
      time += 1000
      subject.add(time)
    end

    subject.phi(time + 1000).should be < 0.5
  end

  it 'should have a high phi value after ten seconds' do
    time = 0
    0.upto(100) do |i|
      time += 1000
      subject.add(time)
    end

    subject.phi(time + 10000).should be > 4

  end

  it 'should only keep last 1000 values' do
    time = 0
    0.upto(2000) do |i|
      time += 1000
      subject.add(time)
    end

    subject.intervals.size.should == 1000
  end

  it 'should be empty with no intervals' do
    subject.should be_empty
    subject.add(Time.now.to_i)
    subject.should_not be_empty
  end

end

