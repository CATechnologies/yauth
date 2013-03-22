require_relative "../../spec_helper"
require 'rack'

describe Strategies::Password do
  let(:manager) { mock "Manager" }
  let(:base_path) { ROOT + "tmp" }

  subject { Strategies::Password.new({}, nil, base_path, 'username', 'password') }

  it { subject.should respond_to(:authenticate!) }

  it "should get a manager instance" do
    UserManager.should_receive(:instance).with(base_path).and_return(manager)
    subject #needed to initialize the subject
  end

  describe "with a manager instance" do
    let(:request) { mock "Request" }
    let(:params) { {'username' => 'foo', 'password' => 'secret'} }

    before(:each) do
      UserManager.stub(:instance).and_return(manager)

      env = mock "Env"
      subject.should_receive(:env).and_return(env)
      request.stub(:params).and_return(params)
      Rack::Request.should_receive(:new).with(env).and_return(request)
    end

    it "should authenticate if valid credentials are passed" do
      user = mock "user"
      manager.should_receive(:authenticate).with('foo', 'secret').and_return(user)
      subject.should_receive(:success!).with(user)
      subject.authenticate!
    end

    it "should not authenticate if there are no credentials" do
      params.stub("[]").ordered.with('username').and_return(nil)
      params.stub("[]").ordered.with('password').and_return(nil)

      subject.should_receive(:fail!).with("Failed to Login")
      subject.should_not_receive(:success!)
      subject.authenticate!
    end

    it "should not authenticate if credentials don't match" do
      manager.should_receive(:authenticate).with('foo', 'secret').and_return(nil)
      subject.should_receive(:fail!).with("Failed to Login")
      subject.should_not_receive(:success!)
      subject.authenticate!
    end
  end
end

describe Strategies::Password, "as a class" do
  it "should install itself into Warden" do
    Warden::Strategies.should_receive(:add).with(:yauth_strategy_password, Strategies::Password)
    Strategies::Password.install!
  end 
end
