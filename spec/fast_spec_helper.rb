# Get your specs running without loading all the Hydra dependencies
ENV['RAILS_ENV'] ||= 'test'
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
  SimpleCov.command_name 'spec'
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!

  # When issue https://github.com/ndlib/curate_nd/issues/423 is resolved
  # * Restore config.order = 'random'
  # * Remove config.seed = '44282'
  # config.order = 'random'
  config.seed = '44282'

  config.use_transactional_fixtures = false
end
