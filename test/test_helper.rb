ENV["RAILS_ENV"] = "test"
require 'simplecov'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'rspec/expectations/minitest_integration'
require 'mocha/minitest'

Dir[File.join(Rails.root, 'features', 'factories', '**', '*.rb')].each do |file|
  load(file)
end

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
end
