source 'https://rubygems.org'

# This should be everything except :deploy; And by default, we mean any of
# the environments that are not used to execute the deploy scripts
group :default do
  gem 'mysql2'
  gem 'curate', git: 'git://github.com/jeremyf/curate.git', branch: 'refactoring-towards-sufia-models'
  gem 'sufia-models', git: 'git://github.com/jeremyf/sufia.git', branch: 'remove-rmagick-dependency'
  gem 'active-fedora', git: 'git://github.com/projecthydra/active_fedora.git'
  gem 'rsolr'
  gem 'nokogiri', "~>1.6.0"
  gem 'jettywrapper'
  gem 'jquery-rails'
  gem 'decent_exposure'
  gem 'devise_cas_authenticatable'
  gem 'rake'
  gem 'resque-pool'
  gem 'morphine'
  gem "unicode", :platforms => [:mri_18, :mri_19]
  gem "devise"
  gem "devise-guests", "~> 0.3"
  # Need rubyracer to run integration tests.....really?!?
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'bootstrap-datepicker-rails'
  gem 'namae'
  gem 'net-ldap'
end

group :pre_production, :production do
  gem "sentry-raven"
end

group :headless do
  gem 'clamav'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'bootstrap-sass', '~> 2.2.0'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'capybara', "~> 2.1"
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'timecop'
  gem 'poltergeist'
end

group :debug do
  gem 'debugger', ">= 1.4"
  gem 'rails_best_practices'
  gem 'sextant'
  gem 'simplecov'
  gem 'method_locator'
end

group :deploy do
  gem 'capistrano'
end