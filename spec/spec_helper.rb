$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))

require 'rails'
require 'active_record'
require 'action_controller'
require 'action_view'
require 'delorean'
require 'millstone'

require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Delorean
  config.mock_with :rspec
  config.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
  config.use_transactional_fixtures = true
end

CreateTestTables.up

