$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'yauth'
require 'stringio'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

include Yauth
Yauth.location = "tmp/config/users.yml"

ROOT = Pathname.new(File.dirname(__FILE__)) + "../"

RSpec.configure do |config|
  
end
