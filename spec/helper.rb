require 'webmock/rspec'
require 'database_cleaner/active_record'
require 'byebug'

ENV['ENV'] = 'test'
Dir["./lib/**/*.rb"].each {|file| require file }

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
