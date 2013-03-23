
class Yauth::User

  include BCrypt

  attr_accessor :username, :password
  attr_reader :plain_password

  def initialize(hash={})
    hash = hash[:user] if hash[:user]
    hash = hash["user"] if hash["user"]

    self.username = hash[:username] || hash["username"]
    _password = hash[:password] || hash["password"]
    self.password = _password ? Password.new(_password) : _password
  end

  def plain_password=(plain_password)
    self.password = Password.create(plain_password)
    @plain_password = plain_password
  end
  
  def to_hash
    { "user" => { "username" => username, "password" => password.to_s.force_encoding("UTF-8") } }
  end

  def to_yaml(opts={})
    to_hash.to_yaml(opts)
  end

  def authenticate(password)
    return false if password.to_s == "" 
    self.password == password
  end
end
