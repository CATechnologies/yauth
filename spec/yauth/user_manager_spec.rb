require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserManager do
  subject { UserManager.new(Yauth.location) }

  let(:yml_location) { Pathname.new(Yauth.location) }

  [:add, :remove, :each, :save].each do |m|
    it do
      should respond_to(m)
    end
  end

  def mock_user(name)
    user = mock "user #{name}"
    user.stub(:username).and_return(name)
    user
  end

  it "should add a user" do
    user = mock_user "user"
    subject.add user
    subject.to_a.should == [user]
  end

  it "should not add the same user twice" do
    user = mock_user "user"
    subject.add user
    subject.add user
    subject.to_a.should == [user]
  end

  it "should remove a user given its username" do
    user = mock_user "name"
    subject.add user
    subject.remove("name").should == user
    subject.to_a.should == []
  end

  it "should yield each added user" do 
    first = mock_user "first"
    second = mock_user "second"
    subject.add first
    subject.add second
    expect {|b|
      subject.each(&b)
    }.to yield_successive_args(first, second)
  end

  it "should save all its users to the specified file" do
    first = User.new(:username => "first", :password => encrypt("123"))
    second = User.new(:username => "second")
    second.plain_password = '456'
    subject.add(first)
    subject.add(second)

    io = StringIO.new
    subject.should_receive(:open).with(yml_location, "w").and_yield(io)
    subject.save
    io.string.should include(<<-EOF.chop % [["$2a$10$"]*2].flatten)
---
- user:
    username: first
    password: %s
EOF
    io.string.should include(<<-EOF.chop % [["$2a$10$"]*2].flatten)
- user:
    username: second
    password: %s
EOF

  end

  it "should find a user by its username" do
    first = User.new(:username => "first", :password => encrypt("123"))
    second = User.new(:username => "second", :password => encrypt("456"))
    subject.add(first)
    subject.add(second)

    subject.find_by_username("first").should == first
    subject.find_by_username("second").should == second
  end

  it "should authenticate a user by its username and password" do
    user = mock "user"
    subject.should_receive(:find_by_username).with("name").and_return(user)
    user.should_receive(:authenticate).with("password").and_return(true)

    subject.authenticate("name", "password").should == user
  end

  it "should not authenticate a user if the password doesn't match" do
    user = mock "user"
    subject.should_receive(:find_by_username).with("name").and_return(user)
    user.should_receive(:authenticate).with("password").and_return(false)

    subject.authenticate("name", "password").should be_false
  end

  it "should not authenticate if there is no match" do
    subject.should_receive(:find_by_username).with("name").and_return(nil)
    subject.authenticate("name", "password").should be_false
  end

  it "should be able to return the first user" do 
    first = mock_user "first"
    second = mock_user "second"
    subject.add first
    subject.add second
    subject.first.should == first
  end
end

describe UserManager, "as a class" do

  subject { UserManager }

  let(:base_path) { Pathname.pwd }

  it "should mix in Enumerable" do
    subject.ancestors.should include(Enumerable)
  end

  it { should respond_to(:load) }

  describe "#load" do
    it "should load from a yaml file if that file exists" do 
      path = "a/path/to.yml"
      io = StringIO.new <<-EOF
- user:
    username: first
    password: $2a$10$55XKSYQDwBRM2Thg33/kbe9ewF1N0EmCp0YB/8qTLzrEPFONXFyI6
- user:
    username: second
    password: $2a$10$hIOgKNo71iR/zIk5NBpAwufxUmCGqInndKszuvUoL9xg8OYr8yLYi
      EOF
      File.stub(:exists?).with(path).and_return(true)
      UserManager.should_receive(:open).with(path).and_yield(io)
      manager = UserManager.load(path)

      ary = manager.to_a
      ary.size.should == 2

      ary[0].username.should == "first"
      ary[0].password.should == 123456
      ary[1].username.should == "second"
      ary[1].password.should == 789012
    end

    it "should create a new UserManager if the file doesn't exists" do 
      path = "a/path/to.yml"
      File.stub(:exists?).with(path).and_return(false)
      manager = UserManager.load(path)
      manager.to_a.should == []
    end
  end

  it { should respond_to(:add) }
  describe "#add" do
    it "should add a user to the manager with the specified config" do
      manager = mock "Manager"
      UserManager.should_receive(:instance).with(base_path).and_return(manager)

      user = mock "User"
      User.should_receive(:new).and_return(user)
      user.should_receive(:username=).with("bar")
      user.should_receive(:plain_password=).with("foo")

      manager.should_receive(:add).with(user)
      manager.should_receive(:save)
      subject.add("bar", "foo", base_path)
    end
  end

  it { should respond_to(:remove) }
  describe "#remove" do
    it "should remove from the manager with the specified config" do
      manager = mock "Manager"

      UserManager.should_receive(:instance).with(base_path).and_return(manager)
      manager.should_receive(:remove).with("bar")
      manager.should_receive(:save)

      subject.remove("bar", base_path)
    end
  end

  it { should respond_to(:instance) }
  describe "#instance" do
    it "should return an instance of the manager with the specified base path" do
      manager = mock "Manager"
      UserManager.should_receive(:load).with(base_path + Yauth.location).and_return(manager)

      subject.instance(base_path)
    end
  end

  it { should respond_to(:first) }
  describe "#first" do
    it "should return the first user from the specified config" do
      manager = mock "Manager"

      UserManager.should_receive(:instance).with(base_path).and_return(manager)
      manager.should_receive(:first)

      subject.first(base_path)
    end
  end

  it { should respond_to(:find_by_username) }
  describe "#find_by_username" do
    it "should find a user by username from the specified config" do
      manager = mock "Manager"

      UserManager.should_receive(:instance).with(base_path).and_return(manager)
      manager.should_receive(:find_by_username).with('jack')

      subject.find_by_username('jack', base_path)
    end
  end

end
