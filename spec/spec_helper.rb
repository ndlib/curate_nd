# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
  SimpleCov.command_name "spec"
end
require File.expand_path("../../config/environment", __FILE__)
require 'curate/spec_support'

require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'
require 'capybara/rspec'
require 'webmock/rspec'
require 'timeout'
require 'active_fedora/test_support'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true)
end

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!


  # When issue https://github.com/ndlib/curate_nd/issues/423 is resolved
  # * Restore config.order = 'random'
  # * Remove config.seed = '44282'
  # config.order = 'random'
  config.seed = '44282'

  config.use_transactional_fixtures = false

  config.before(:each, type: :feature) do
    Warden.test_mode!
    @old_resque_inline_value = Resque.inline
    Resque.inline = true
  end
  config.after(:each, type: :feature) do
    begin
      if example.exception.present? && defined?(page)
        filename = example.location.gsub(/\A\W+/,'').gsub(/\W+/,'-') << '.png'
        page.save_screenshot(Rails.root.join("tmp/#{filename}"), full: true)
        `open #{Rails.root.join("tmp/#{filename}")}`
      end
    rescue
      # It could've been so nice.
    end
    Warden.test_reset!
    Resque.inline = @old_resque_inline_value
  end


  config.before(:suite) do
    ActiveFedora::TestCleaner.setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:all) do
    WebMock.allow_net_connect!
    VCR.configure do |c|
      c.cassette_library_dir = "spec/fixtures/cassettes"
      c.hook_into :webmock
      c.ignore_localhost = false
      c.allow_http_connections_when_no_cassette = true
    end
  end

  config.before(:each) do
    ActiveFedora::TestCleaner.start
    DatabaseCleaner.start
    User.any_instance.stub(:ldap_service).and_return(nil)
    User.any_instance.stub_chain(:ldap_service, :display_name).and_return(nil)
    User.any_instance.stub_chain(:ldap_service, :preferred_email).and_return(nil)
    allow_message_expectations_on_nil

  end

  config.after(:each) do
    ActiveFedora::TestCleaner.clean
    DatabaseCleaner.clean
  end

end
