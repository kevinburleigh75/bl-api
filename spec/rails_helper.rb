# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require 'database_cleaner'
require 'support/factory_bot'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.before(:suite) do
    # DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.use_transactional_fixtures = false

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = false

  # config.before(:suite) do
  #   DatabaseCleaner.clean_with(:truncation)
  # end

  # config.prepend_before(:all) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.start
  # end

  # config.before(:each) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

  # config.append_after(:all) do
  #   DatabaseCleaner.clean
  # end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

##
## Convenience function to make parameters explicit
## and their ordering irrelavent.
##
def make_post_request(route:, headers: nil, body: nil)
  post route, params: body, headers: headers
end

##
## Compares hashes with arbitrary keys whose values
## are ActiveRecord objects (whose default == operator
## does not support normal equality semantics).
##

RSpec::Matchers.define :the_same_records_as do |expected|
  match do |actual|
    ## same keys
    result = expected.keys.sort == actual.keys.sort
    break result unless result

    result = expected.keys.each do |key|
      expected_records = expected[key]
      actual_records   = actual[key]

      ## same type of values
      break false if expected_records.kind_of?(Array) != actual_records.kind_of?(Array)

      expected_records_arr = Array(expected_records)
      actual_records_arr   = Array(actual_records)

      ## same number of values
      break false if expected_records_arr.count != actual_records_arr.count

      ## everybody is an ActiveRecord
      break false unless expected_records_arr.all?{|record| record.kind_of?(ActiveRecord::Base)}
      break false unless actual_records_arr.all?{|record| record.kind_of?(ActiveRecord::Base)}

      ## same values (order doesn't matter)
      result = expected_records_arr.each do |expected_record|
        break false unless actual_records_arr.detect{|actual_record| actual_record.attributes == expected_record.attributes}
        true
      end
      break result unless result
    end
    result
  end
end
