module Yauth
  module Strategies
    class Password < Warden::Strategies::Base

      attr_reader :manager, :user_field, :password_field

      def initialize(env, scope, base_path = Pathname.new(""), user_field = 'username', password_field = 'password')
        super(env, scope)
        @user_field = user_field
        @password_field = password_field
        @manager = Yauth::UserManager.instance(base_path)
      end

      def authenticate!
        request = Rack::Request.new(env)
        user = request.params[@user_field]
        password = request.params[@password_field]
        credentials = [user, password]

        if (user && password) && (user = manager.authenticate(*credentials))
          success!(user)
        else
          fail!("Failed to Login")
        end
      end

      def self.install!
        Warden::Strategies.add(:yauth_strategy_password, self)
      end
    end
  end
end
