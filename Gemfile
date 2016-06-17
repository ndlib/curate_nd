source 'https://rubygems.org'

# This should be everything except :deploy; And by default, we mean any of
# the environments that are not used to execute the deploy scripts
group :default do
  gem 'active_attr'
  gem 'active_fedora-registered_attributes', '~> 0.2.0'
  gem 'bootstrap-datepicker-rails'
  gem 'breach-mitigation-rails'
  gem 'breadcrumbs_on_rails'
  gem 'browser'
  gem 'chronic', '>= 0.10.2'
  gem 'citeproc-ruby', '~> 1.1'
  gem 'csl-styles', '~> 1.0'
  gem 'curate-indexer'
  gem 'custom_configuration'
  gem 'decent_exposure'
  gem 'devise', '~>3.2.2'
  gem 'devise-guests', '~> 0.3'
  gem 'devise-multi_auth', github: 'jeremyf/devise-multi_auth'
  gem 'devise_cas_authenticatable'
  gem 'devise_masquerade'
  gem 'flipper'
  gem 'harbinger', git: 'git://github.com/ndlib/harbinger'
  gem 'blacklight-hierarchy', github: 'ndlib/blacklight-hierarchy', branch: 'master'
  gem 'httparty'
  gem 'hydra-batch-edit', '~> 1.1.1'
  gem 'hydra-collections', '~> 1.3.0'
  gem 'hydra-derivatives', '~> 0.0.7'
  gem 'hydra-file_characterization', ">= 0.2.3"
  gem 'hydra-remote_identifier', '~> 0.6', '>= 0.6.7'
  gem 'jettywrapper'
  gem 'jquery-rails'
  gem 'jshintrb'
  gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'
  # Need rubyracer to run integration tests.....really?!?
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'libv8', '~> 3.16.14.3'
  gem 'locabulary', github: 'ndlib/locabulary', branch: 'master'
  gem 'lograge'
  gem 'logstash-event'
  gem 'logstash-logger'
  gem 'mini_magick', '~> 3.8'
  gem 'morphine'
  gem 'mysql2'
  gem 'namae'
  gem 'net-ldap'
  gem 'newrelic_rpm'
  gem 'noids_client', git: 'git://github.com/ndlib/noids_client'
  gem 'nokogiri', "~>1.6.0"
  gem 'orcid', github: 'projecthydra-labs/orcid'
  gem 'qa'
  gem 'rails', '~>4.0.2'
  gem 'rails_autolink'
  gem 'rake'
  gem 'redcarpet'
  gem 'resque-pool'
  gem 'roboto'
  gem 'rubydora', '~> 1.7.4'
  gem 'sanitize', '~> 3.0.2'
  gem 'select2-rails'
  gem 'simple_form', '~> 3.0.1'
  gem 'sufia-models', '~>3.4.0'
  gem 'therubyracer', '0.12.1', platforms: :ruby, require: 'v8'
  gem 'unicode', :platforms => [:mri_18, :mri_19]
  gem 'unicorn', '~> 4.0'
  gem 'virtus'
end

group :headless do
  gem 'clamav'
end

# Hack to work around some bundler strangeness
#
# This gem was appearing in the lock file, but was not
# being listed in a `bundle list` command on the staging machine.
# Explicitly require it here.
gem 'addressable', '~> 2.3.5'
gem 'coffee-rails', '~> 4.0'
gem 'compass-rails', '~> 1.1.2'
gem 'sass-rails',   '~> 4.0'
gem 'uglifier', '>= 1.0.3'

gem 'rails-assets-leaflet', source: 'https://rails-assets.org'
gem 'rails-assets-Leaflet--Leaflet.fullscreen', source: 'https://rails-assets.org'

group :test do
  gem 'capybara', "~> 2.4"
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~>4.2.0'
  gem 'poltergeist', '~> 1.5'
  gem 'rspec-html-matchers', '~>0.6'
  gem 'rspec-its', '~> 1.0'
  gem 'rspec-rails', '~>3.0'
  gem 'test_after_commit'
  gem 'vcr'
  gem 'webmock'
end

group :debug do
  gem 'method_source'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms => [:mri_19, :mri_20, :rbx]
  gem 'byebug'
  gem 'quiet_assets'
  gem 'rails_best_practices'
  gem 'sextant'
  gem 'simplecov'
  gem 'thin'
  gem 'ruby-beautify'
end

group :deploy do
  gem 'capistrano', '~> 2.15'
end

group :development do
  gem 'meta_request'
  gem 'rubocop', require: false
  gem 'scss-lint', require: false
end
