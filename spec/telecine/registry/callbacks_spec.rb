require 'spec_helper'

describe Telecine::Registry::Callbacks do
    
  # on_update
  # on_*
  # callbacks
end

describe Telecine::Registry::Callbacks::Callback do
  it 'should allow nil key and action' do
    subject.key.should be_nil
    subject.action.should be_nil
  end

  it 'should be cancelable' do
    subject.should be_active
    subject.cancel
    subject.should_not be_active
  end

  context 'subscriptions' do
    it 'should subscribe to a key, action pair' do
      subject = described_class.new(:foo, :set)
      subject.subscribed_to?(:foo, :set).should be_true
      subject.subscribed_to?(:foo2, :set).should_not be_true
      subject.subscribed_to?(:foo, :remove).should_not be_true
    end

    it 'should subscribe to any key' do
      subject = described_class.new(nil, :set)
      subject.subscribed_to?(:foo, :set).should be_true
      subject.subscribed_to?(:foo2, :set).should be_true
      subject.subscribed_to?(:foo2, :remove).should_not be_true
    end

    it 'should subscribe to any action' do
      subject = described_class.new(:foo, nil)
      subject.subscribed_to?(:foo, :set).should be_true
      subject.subscribed_to?(:foo, :remove).should be_true
      subject.subscribed_to?(:foo2, :remove).should_not be_true
    end

    it 'should subscribe to any key or action' do
      subject.subscribed_to?(:foo, :set).should be_true
      subject.subscribed_to?(:foo2, :remove).should be_true
    end
  end

  context 'call' do
    let(:block) { ->(*args) { args } } 

    it 'should call block with unrestricted key or action' do
      subject = described_class.new(&block)
      subject.call(:foo, :set, '1', '2').should == [:foo, :set, '1', '2']
    end

    it 'should call block with restricted key' do
      subject = described_class.new(:foo, &block)
      subject.call(:foo, :set, '1', '2').should == [:set, '1', '2']
    end

    it 'should call block with restricted action' do
      subject = described_class.new(nil, :set, &block)
      subject.call(:foo, :set, '1', '2').should == [:foo, '1', '2']
    end

    it 'should call block with restricted key and action' do
      subject = described_class.new(:foo, :set, &block)
      subject.call(:foo, :set, '1', '2').should == ['1', '2']
    end
  end
end
