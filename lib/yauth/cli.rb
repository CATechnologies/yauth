class Yauth::CLI < Thor

  desc "add USERNAME PASSWORD", "Adds or updates a user"
  method_options :config => Yauth.location
  def add(username, password)
    set_location(options[:config])
    Yauth::UserManager.add(username, password, Pathname.pwd)
  end

  desc "rm USERNAME", "Remove a user"
  method_options :config => Yauth.location
  def rm(username)
    set_location(options[:config])
    Yauth::UserManager.remove(username, Pathname.pwd)
  end

  private

  def set_location(config)
    Yauth.location = config
  end
end
