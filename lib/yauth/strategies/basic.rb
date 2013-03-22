
module Yauth
  module Strategies
    class Basic < Warden::Strategies::Base

      attr_reader :manager

      def initialize(env, scope, base_path = Pathname.new(""))
        super(env, scope)
        @manager = Yauth::UserManager.instance(base_path)
      end

      def authenticate!
        auth = Rack::Auth::Basic::Request.new(env)
        credentials = auth.provided? && auth.basic? && auth.credentials
        if not credentials or not user = manager.authenticate(*credentials)
          fail!("Could not log in") 
        else
          success!(user)
        end
      end

      def self.install!
        Warden::Strategies.add(:yauth_users, self) # Backward compatibility
        Warden::Strategies.add(:yauth_strategy_basic, self)
      end
    end
  end
end
