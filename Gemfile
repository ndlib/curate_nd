source 'https://rubygems.org'

# This should be everything except :deploy; And by default, we mean any of
# the environments that are not used to execute the deploy scripts
group :default do
  gem 'mysql2'
  gem 'curate', github: 'ndlib/curate', branch: 'curate-nd-beta', ref: '7b937e627b7571db3f8476853ee8affca5e6a11b'
  # gem 'curate', path: '../curate'
  gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'
  # gem 'active-fedora', github: 'jeremyf/active_fedora', branch: 'fixing-rdf-datastream-encoding'
  gem 'orcid', github: 'projecthydra-labs/orcid'
  gem 'devise-multi_auth', github: 'jeremyf/devise-multi_auth'
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
  gem "devise", "~>3.2.2"
  gem "devise-guests", "~> 0.3"
  # Need rubyracer to run integration tests.....really?!?
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'libv8', '3.16.14.3'
  gem 'therubyracer', '0.12.1', platforms: :ruby, require: 'v8'
  gem 'bootstrap-datepicker-rails'
  gem 'namae'
  gem 'unicorn', '~> 4.0'
  gem 'net-ldap'
  gem 'custom_configuration'
  gem 'noids_client', git: 'git://github.com/ndlib/noids_client'
  gem 'harbinger', git: 'git://github.com/ndlib/harbinger'
  gem 'newrelic_rpm'
  gem 'flipper'
  gem 'roboto'
  gem 'hesburgh-lib', github: 'ndlib/hesburgh-lib'
end

# Hack to work around some bundler strangeness
#
# This gem was appearing in the lock file, but was not
# being listed in a `bundle list` command on the staging machine.
# Explicitly require it here.
gem 'addressable', '~> 2.3.5'

group :headless do
  gem 'clamav'
end

gem 'coffee-rails', '~> 4.0'
gem 'compass-rails', '~> 1.1.2'
gem 'sass-rails',   '~> 4.0'
gem 'uglifier', '>= 1.0.3'

group :development do
  gem 'spring'
  gem "spring-commands-rspec"
end

group :test do
  gem 'capybara', "~> 2.4"
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~>4.2.0'
  gem 'rspec-html-matchers', '~>0.6'
  gem 'rspec-rails', '~>3.0'
  gem 'rspec-its', '~> 1.0'
  gem 'vcr'
  gem 'webmock'
  gem 'timecop'
  gem 'poltergeist', '~> 1.5'
  gem 'test_after_commit'
end

group :debug do
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms => [:mri_19, :mri_20, :rbx]
  gem 'rails_best_practices'
  gem 'sextant'
  gem 'simplecov'
  gem 'method_locator'
  gem 'byebug'
  gem 'thin'
end

group :deploy do
  gem 'capistrano', '~> 2.15'
end
