require File.join(File.dirname(__FILE__), "..", "spec_helper")
require 'fileutils'

describe CLI do

  subject { CLI.new }

  let(:options) { { :config => Yauth.location } }

  before :each do
    subject.stub!(:options).and_return(options)
  end

  [:add, :rm].each do |m|
    it { should respond_to(m) }
  end

  describe "#add" do
    before :each do
      UserManager.stub(:add)
    end

    it "should set the configured location" do
      subject.should_receive(:set_location).with(Yauth.location)
      subject.add("bar", "foo")
    end

    it "should delegate adding a user to the manager with the specified config" do
      UserManager.should_receive(:add).with("bar", "foo", instance_of(Pathname))
      subject.add("bar", "foo")
    end
  end

  describe "#remove" do
    before :each do
      UserManager.stub(:remove)
    end

    it "should set the configured location" do
      subject.should_receive(:set_location).with(Yauth.location)
      subject.rm("bar")
    end

    it "should delagate removing a user to the manager with the specified config" do
      UserManager.should_receive(:remove).with("bar", instance_of(Pathname))

      subject.rm("bar")
    end
  end
end
