require 'spec_helper'

describe Telecine::Router::Message::Envelope do
  it 'should set defaults' do
    subject.id.should_not be_nil
    subject.version.should == Telecine::Router::Message::VERSION
    subject.headers.should == []
  end

  it 'should generate a unique id' do
    subject.id.should_not == described_class.new.id
  end

  it 'should generate parts' do
    subject.version = "1"
    subject.id = "2"
    subject.headers = ["3", "4"]
    subject.to_parts.should == ["1", "2", "3", "4", ""]
  end

  it 'should parse parts' do
    parts = ["1", "2", "3", "4", ""]

    envelope = described_class.parse(parts)
    envelope.version.should == "1"
    envelope.id.should == "2"
    envelope.headers.should == ["3", "4"]
  end
  
  it 'should convert elements to strings' do
    parts = [1, 2, 3, 4, ""]

    envelope = described_class.parse(parts)
    envelope.to_parts.should == ["1", "2", "3", "4", ""]
  end
end

describe Telecine::Router::Message do
  it 'should create an envelope' do
    subject.envelope.should be_a(Telecine::Router::Message::Envelope)
  end

  it 'should delegate getters to envelope' do
    envelope = Telecine::Router::Message::Envelope.parse(["1", "2", "3", "4", ""])
    subject.envelope = envelope

    subject.version.should == "1"
    subject.id.should == "2"
    subject.headers.should == ["3", "4"]
  end

  it 'should delegate setters to envelope' do
    subject.id = "foo"
    subject.envelope.id.should == "foo"
    subject.version = "bar"
    subject.envelope.version.should == "bar"
    subject.headers = ["baz"]
    subject.envelope.headers.should == ["baz"]
  end

  it 'should parse the envelope and message parts' do
    parts = ["1", "2", "3", "4", "", "arg1", "arg2"]

    message = described_class.parse(parts)
    message.envelope.version.should == "1"
    message.envelope.id.should == "2"
    message.envelope.headers.should == ["3", "4"]
    message.parts.should == ["arg1", "arg2"]
  end

  it 'should generate parts' do
    subject.version = "1"
    subject.id = "2"
    subject.headers = ["3", "4"]
    subject.parts = ["arg1", "arg2"]
    subject.to_parts.should == ["1", "2", "3", "4", "", "arg1", "arg2"]
  end

  it 'should convert elements to strings' do
    parts = [1, 2, 3, 4, "", :arg1, :arg2]

    envelope = described_class.parse(parts)
    envelope.to_parts.should == ["1", "2", "3", "4", "", "arg1", "arg2"]
  end
end
