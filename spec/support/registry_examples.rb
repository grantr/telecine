shared_examples "a Registry" do
  it 'should return nil if missing' do
    subject.get('nothing').should be_nil
  end

  it 'should set values' do
    subject.set('foo', :bar).should == :bar
    subject.get('foo').should == :bar
  end

  it 'should remove values' do
    subject.set('foo', :bar)
    subject.remove('foo')
    subject.get('foo').should be_nil
  end

  it 'should be indifferent access' do
    subject.set('foo', :bar)
    subject.get('foo').should == :bar
    subject.get(:foo).should == :bar
    subject.set(:foo, :baz)
    subject.get('foo').should == :baz
    subject.remove('foo')
    subject.get(:foo).should be_nil
  end

  it 'should have a unique id' do
    subject._id.should_not be_nil
    described_class.new._id.should_not == subject._id
  end

  it 'should take block default arg' do
    subject = described_class.new { "foo" }
    subject.get(:foo).should == "foo"
  end

  context 'getset' do
    it 'should set missing values from a block' do
      subject.get('foo') { :bar }.should == :bar
      subject.get('foo').should == :bar
    end

    it 'should be threadsafe' do
      t1 = Thread.new do
        subject.get('foo') { sleep 2; :bar }
      end
      t2 = Thread.new do
        sleep 1;
        subject.get('foo').should == :bar
      end

      t1.join
      t2.join
    end
  end

  it 'should put the id in the topic' do
    subject._topic.should match(subject._id)
  end

  context "publishing" do
    let(:subscriber) { Subscriber.new }

    it 'should publish sets' do
      subscriber.subscribe("#{subject._topic}.foo.set")

      subject.set(:foo, 'bar')
      subject.set(:foo, 'baz')

      sleep Celluloid::TIMER_QUANTUM
      subscriber.events.first.should == [subject._id, :foo, :set, nil, 'bar']
      subscriber.events.last.should  == [subject._id, :foo, :set, 'bar', 'baz']
    end

    it 'should publish removes' do
      subscriber.subscribe("#{subject._topic}.foo.remove")

      subject.set(:foo, 'bar')
      subject.remove(:foo)

      sleep Celluloid::TIMER_QUANTUM
      subscriber.events.first.should == [subject._id, :foo, :remove, 'bar', nil]
      subscriber.terminate
    end

    it 'should publish array add and remove' do
      subscriber.subscribe("#{subject._topic}.foo.add_element")
      subscriber.subscribe("#{subject._topic}.foo.remove_element")

      subject.set(:foo, [])
      subject.set(:foo, ['1', '2'])
      subject.set(:foo, ['2'])

      sleep Celluloid::TIMER_QUANTUM
      subscriber.events[0].should == [subject._id, :foo, :add_element, nil, '1']
      subscriber.events[1].should == [subject._id, :foo, :add_element, nil, '2']
      subscriber.events[2].should == [subject._id, :foo, :remove_element, '1', nil]
    end
  end
end
