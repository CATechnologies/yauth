require 'yaml'
require 'thor'
require 'warden'
require 'bcrypt'

module Yauth
  class << self
    attr_accessor :location
  end
  Yauth.location = "config/users.yml"
end

require_relative "yauth/user"
require_relative "yauth/user_manager"
require_relative "yauth/cli"
require_relative "yauth/strategies/basic"
require_relative "yauth/strategies/password"
require_relative "yauth/failure_app"
