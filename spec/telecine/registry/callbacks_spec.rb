require 'spec_helper'

describe Telecine::Registry::Callbacks do
  let(:registry) { Telecine::Registry.new }
  let(:callback_listener) { CallbackListener.new }
  let(:block) { ->(*args) { callback_listener.callback_args = args } }

  it 'should run on_update callback with no key or action' do
    callback_listener.on_update registry, &block
    registry.set(:foo, :bar)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:foo, :set, nil, :bar]
  end

  it 'should run on_update callback with a key' do
    callback_listener.on_update registry, :foo, &block
    registry.set(:foo, :bar)
    registry.set(:foo2, :bar2)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:set, nil, :bar]
  end

  it 'should run on_update callback with an action' do
    callback_listener.on_update registry, nil, :set, &block
    registry.set(:foo, :bar)
    registry.remove(:foo)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:foo, nil, :bar]
  end

  it 'should run on_update callback with a key and action' do
    callback_listener.on_update registry, :foo, :set, &block
    registry.set(:foo, :bar)
    registry.set(:foo2, :bar2)
    registry.remove(:foo)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [nil, :bar]
  end

  it 'should run on_set callback with a key' do
    callback_listener.on_set registry, :foo, &block
    registry.set(:foo, :bar)
    registry.set(:foo2, :bar2)
    registry.remove(:foo)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [nil, :bar]
  end

  it 'should run on_set callback with no key' do
    callback_listener.on_set registry, &block
    registry.set(:foo, :bar)
    registry.remove(:foo)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:foo, nil, :bar]
  end

  it 'should run on_remove callback with a key' do
    callback_listener.on_remove registry, :foo, &block
    registry.set(:foo, :bar)
    registry.remove(:foo)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:bar, nil]
  end

  it 'should run on_remove callback with no key' do
    callback_listener.on_remove registry, &block
    registry.set(:foo, :bar)
    registry.remove(:foo)

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:foo, :bar, nil]
  end

  it 'should run on_add_element callback with a key' do
    callback_listener.on_add_element registry, :foo, &block
    registry.set(:foo, [])
    registry.set(:foo, ['1'])

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [nil, '1']
  end

  it 'should run on_add_element callback with no key' do
    callback_listener.on_add_element registry, &block
    registry.set(:foo, [])
    registry.set(:foo, ['1'])

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:foo, nil, '1']
  end

  it 'should run on_remove_element callback with a key' do
    callback_listener.on_remove_element registry, :foo, &block
    registry.set(:foo, ['1', '2'])
    registry.set(:foo, ['1'])

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == ['2', nil]
  end

  it 'should run on_remove_element callback with no key' do
    callback_listener.on_remove_element registry, &block
    registry.set(:foo, ['1', '2'])
    registry.set(:foo, ['1'])

    sleep Celluloid::TIMER_QUANTUM

    callback_listener.callback_args.should == [:foo, '2', nil]
  end
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
