require 'pathname'

class Yauth::UserManager
  class Users < Array
    def to_yaml
      self.map(&:to_hash).to_yaml
    end
  end

  include Enumerable

  attr_accessor :path

  def initialize(path)
    @list = Users.new
    @path = Pathname.new(path)
    unless @path.exist?
      @path.dirname.mkpath
    end
  end

  def self.add(config_base_path, username, password)
    #TODO: Move into user initializer
    user = Yauth::User.new
    user.username = username
    user.plain_password = password
    @manager = self.instance(config_base_path)
    @manager.add(user)
    @manager.save
  end

  def self.remove(config_base_path, username)
    @manager = self.instance(config_base_path)
    @manager.remove(username)
    @manager.save
  end

  def self.instance(config_base_path)
    @manager = Yauth::UserManager.load(config_base_path + Yauth.location)
  end

  def add(user)
    remove(user.username)
    @list << user
  end

  def remove(name)
    @list.delete(find_by_username(name))
  end

  def each(&block)
    @list.each(&block)
  end

  def save
    open(@path, "w") do |io|
      io << @list.to_yaml
    end
  end

  def find_by_username(name)
    @list.find { |u| u.username == name }
  end

  def authenticate(username, password)
    user = find_by_username(username)
    user if user and user.authenticate(password)
  end

  def self.load(path)
    manager = self.new(path)
    return manager unless File.exists? path
    open(path) do |io|
      YAML.load(io).each { |h| manager.add(Yauth::User.new(h)) }
    end
    manager
  end
end
