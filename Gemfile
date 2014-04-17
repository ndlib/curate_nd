source 'https://rubygems.org'

# This should be everything except :deploy; And by default, we mean any of
# the environments that are not used to execute the deploy scripts
group :default do
  gem 'mysql2'
  gem 'curate', github: 'ndlib/curate', branch: 'develop-curatend'
  gem 'active-fedora', github: 'jeremyf/active_fedora', branch: 'fixing-rdf-datastream-encoding'
  gem 'nokogiri', "~>1.6.0"
  gem 'jettywrapper'
  gem 'jquery-rails'
  gem 'decent_exposure'
  gem 'devise_cas_authenticatable'
  gem 'devise_masquerade'
  gem 'rake'
  gem 'resque-pool'
  gem 'morphine'
  gem "unicode", :platforms => [:mri_18, :mri_19]
  gem "devise", "~>3.0.3"
  gem "devise-guests", "~> 0.3"
  # Need rubyracer to run integration tests.....really?!?
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'bootstrap-datepicker-rails'
  gem 'namae'
  gem 'unicorn', '~> 4.0'
  gem 'net-ldap'
  gem 'custom_configuration'
end

# Hack to work around some bundler strangeness
#
# This gem was appearing in the lock file, but was not
# being listed in a `bundle list` command on the staging machine.
# Explicitly require it here.
gem 'addressable', '~> 2.3.5'

group :pre_production, :production do
  gem "sentry-raven"
end

group :headless do
  gem 'clamav'
end

gem 'coffee-rails', '~> 4.0'
gem 'compass-rails', '~> 1.1.2'
gem 'sass-rails',   '~> 4.0'
gem 'uglifier', '>= 1.0.3'

group :test do
  gem 'capybara', "~> 2.1"
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'vcr'
  gem 'webmock'
  gem 'timecop'
  gem 'poltergeist'
  gem 'test_after_commit'
end

group :debug do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms => [:mri_19, :mri_20, :rbx]
  gem 'debugger', ">= 1.4"
  gem 'rails_best_practices'
  gem 'sextant'
  gem 'simplecov'
  gem 'method_locator'
  gem 'byebug'
end

group :deploy do
  gem 'capistrano', '~> 2.15'
end
