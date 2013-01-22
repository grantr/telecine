require 'spec_helper'

describe Telecine::Configurable do
  class ConfiguredClass
    include Telecine::Configurable
  end

  it 'should add a config method' do
    ConfiguredClass.config.should be_a(Telecine::Configuration)
  end

  it 'should be configurable by block' do
    ConfiguredClass.configure do |c|
      c.foo = :bar
    end

    ConfiguredClass.config.foo.should == :bar
  end

  context 'config_accessor' do
    it 'should compile methods on the class' do
      ConfiguredClass.class_eval do
        config_accessor :boo
      end

      ConfiguredClass.respond_to?(:boo).should be_true
      ConfiguredClass.boo = :hoo
      ConfiguredClass.boo.should == :hoo
      ConfiguredClass.config.boo.should == :hoo
    end

    it 'should take multiple attribute names' do
      ConfiguredClass.class_eval do
        config_accessor :one, :two
      end

      ConfiguredClass.respond_to?(:one).should be_true
      ConfiguredClass.respond_to?(:two).should be_true
    end
  end

  context '#config' do
    it 'should be a new Configuration' do
      ConfiguredClass.new.config.should be_a(Telecine::Configuration)
      ConfiguredClass.new.config.should_not equal(ConfiguredClass.config)
    end

    it 'should use the class config as parent' do
      config = ConfiguredClass.new.config
      ConfiguredClass.config.set(:inherited, "parent")
      config.get(:inherited).should == "parent"
      config.set(:inherited, "child")
      config.get(:inherited).should == "child"
      ConfiguredClass.config.get(:inherited).should == "parent"
    end
  end

end
