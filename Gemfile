source 'https://rubygems.org'

# Ensure that all github access points are via https
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# This should be everything except :deploy; And by default, we mean any of
# the environments that are not used to execute the deploy scripts
group :default do
  gem 'meta_request'
  gem 'active_attr'
  gem 'active_fedora-registered_attributes', '~> 0.2.0'
  gem 'active-fedora', '~> 6.7.0'
  gem 'activerecord-import'
  gem 'activeresource'
  gem 'acts_as_follower', '>= 0.1.1', '< 0.3'
  gem 'aws-sdk-s3'
  gem 'blacklight-hierarchy', github: 'ndlib/blacklight-hierarchy', branch: 'master'
  gem 'blacklight', "> 4.5.0", '< 7.0'
  gem 'bootstrap-datepicker-rails'
  gem 'breach-mitigation-rails'
  gem 'breadcrumbs_on_rails'
  gem 'bundler', '~> 1.17.3'
  gem 'browser'
  gem 'chronic', '>= 0.10.2'
  gem 'citeproc-ruby', '~> 1.1.0'
  gem 'citeproc'
  gem 'csl-styles'
  gem 'curate-indexer'
  gem 'custom_configuration'
  gem 'decent_exposure'
  gem 'deprecation', '~>0.2.2'
  gem 'devise_masquerade'
  gem 'devise-guests', '~> 0.7'
  gem 'devise', '~>4.7'
  gem 'dry-equalizer', '0.2.2'
  gem 'ezid-client', '~> 1.8'
  gem 'figaro'
  gem 'flipper'
  gem 'httparty'
  gem 'hydra-collections', '~> 1.3.0'
  gem 'hydra-derivatives', '~> 0.0.7'
  gem 'hydra-file_characterization', "~> 0.3.3"
  gem 'hydra-head', "~> 6.4.0"
  gem 'jettywrapper'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
  gem 'jshintrb'
  gem 'json-ld'
  gem 'kaminari'
  gem 'locabulary', github: 'ndlib/locabulary', ref: '9bb8fbefe65569b6f4ea8094a4984415e58851f3'
  gem 'lograge'
  gem 'logstash-event'
  gem 'logstash-logger'
  gem 'mailboxer', '~> 0.11'
  gem 'mini_magick', ">= 4.9.4"
  gem 'morphine'
  gem 'mysql2', '~> 0.3.18'
  gem 'namae'
  gem 'nest', '~> 1.1'
  gem 'noid', '~> 0.6.6'
  gem 'noids_client', github: 'ndlib/noids_client'
  gem 'nokogiri', '~> 1.11'
  gem "oai"
  gem 'omniauth-oktaoauth'
  gem 'rmagick'
  gem 'rails_autolink'
  gem 'rails-observers'
  gem 'rails', '~> 4.2.11.0'
  gem 'rake', '~> 11.0'
  gem 'rdf'
  gem 'redcarpet'
  gem 'redis', '~> 3.3.3' # Necessary as part of upgrade to Rails 4.1.0; added for ruby versioning
  gem 'resque-pool', github: 'ndlib/resque-pool', branch: 'master'
  gem 'roboto'
  gem 'rubydora', '~> 1.7.4'
  gem 'sanitize'
  gem 'sass', '3.4.1' # Maybe necessary as part of upgrade to Rails 4.1.0; added for ruby versioning; at 3.4.25, I encountered "undefined method `log_level' for #<ActiveSupport::Logger:0x0000000a736388>"
  gem 'select2-rails'
  gem 'sentry-raven', '~> 2.7'
  gem 'share_notify', github: 'samvera-labs/share_notify'
  gem 'simple_form', '~> 3.5.0'
  gem 'unicode'
  gem 'unicorn', '~> 4.0'
  gem 'virtus'
  gem 'xpath'
  gem 'rack-mini-profiler'
  gem 'flamegraph'
  gem 'stackprof'
  gem 'memory_profiler'
end

group :headless do
  gem 'clamby'
end

group :orcid do
  gem 'railties', '~> 4.0'
  gem 'omniauth-orcid', '0.6'
  gem 'mappy'
  gem 'email_validator'
  gem 'omniauth-oauth2'
  gem 'hashie', '3.4.6'
end

# Hack to work around some bundler strangeness
#
# This gem was appearing in the lock file, but was not
# being listed in a `bundle list` command on the staging machine.
# Explicitly require it here.
gem 'addressable', '~> 2.8.0'
gem 'sass-rails'
gem 'coffee-rails', '~> 4.0' # needed by sprockets & not included there
gem 'uglifier', '>= 1.0.3'

gem 'rails-assets-leaflet', source: 'https://rails-assets.org'
gem 'rails-assets-Leaflet--Leaflet.fullscreen', source: 'https://rails-assets.org'

group :test do
  gem 'capybara', "~> 2.4"
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~>4.2.0'
  gem 'poltergeist', '~> 1.5'
  gem 'rspec-html-matchers', '~>0.6.1'
  gem 'rspec-its', '~> 1.0.1'
  gem 'rspec-rails', '~>3.1.0'
  gem 'test_after_commit'
  gem 'vcr'
  gem 'webmock'
end

group :debug do
  gem 'method_source'
  gem 'method_locator'
  gem 'better_errors'
  gem 'byebug', '~> 9.0.6' # Necessary as part of upgrade to Rails 4.1.0; added for ruby versioning
  gem 'quiet_assets'
  gem 'rails_best_practices'
  gem 'sextant'
  gem 'simplecov'
  gem 'thin'
  gem 'ruby-beautify'
end

group :deploy do
  gem 'capistrano', '~> 2.15'
  gem 'net-ssh', '~> 4.1.0'
end

group :development do
  gem 'binding_of_caller', :platforms => [:mri_19, :mri_20, :rbx]
  gem 'rubocop', '~> 0.48.1', require: false # Necessary as part of upgrade to Rails 4.1.0; added for ruby versioning
  gem 'rails-erb-lint', require: false
  gem 'scss-lint', require: false
  gem 'brakeman'
end
