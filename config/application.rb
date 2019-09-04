require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # For each of the values of a hash entry, load the hash key's bundle group
  bundle_environment_aliases = Rails.groups(
      default: %w(production pre_production staging development test ci),
      headless: %w(development test ci),
      debug: %w(development test),
      ci: %w(test),
      test: %w(ci)
  )
  Bundler.require(*bundle_environment_aliases)
end

require 'bootstrap-sass'
require 'flipper'
require 'flipper/adapters/memory'

module CurateNd
  class Application < Rails::Application
    require 'curate'
    require 'hydra-access-controls'
    require 'orcid'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{config.root}/app/builders
      #{config.root}/app/constraints
      #{config.root}/app/exceptions
      #{config.root}/app/repository_models
      #{config.root}/app/repository_datastreams
      #{config.root}/app/services
      #{config.root}/app/workers
      #{config.root}/app/models/datastreams
      #{config.root}/app/models/concerns
      #{config.root}/app/validators
      #{config.root}/lib/sufia/models/jobs
      #{config.root}/app/repository_models/hydra
    )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true
    # Default SASS Configuration, check out https://github.com/rails/sass-rails for details
    config.assets.compress = !Rails.env.development?
    config.assets.js_compressor = Uglifier.new(harmony: true)

    config.exceptions_app = lambda { |env| ErrorsController.action(:show).call(env) }
    config.action_dispatch.rescue_responses["ActionController::RoutingError"] = :not_found
    config.action_dispatch.rescue_responses["ActiveFedora::ObjectNotFoundError"] = :not_found
    config.action_dispatch.rescue_responses["ActiveFedora::ActiveObjectNotFoundError"] = :gone
    config.action_dispatch.rescue_responses["Hydra::AccessDenied"] = :unauthorized
    config.action_dispatch.rescue_responses["CanCan::AccessDenied"] = :unauthorized
    config.action_dispatch.rescue_responses["Rubydora::RecordNotFound"] = :not_found

    Curate.configuration.build_identifier = begin
      identifier = Rails.root.join('VERSION').read.strip
      unless Rails.env.production?
        identifier += " (#{Rails.env})"
      end
      identifier
    rescue Errno::ENOENT
      # irreverent message for cats running this on laptops
      "Moof!"
    end
    config.build_identifier = Curate.configuration.build_identifier

    config.to_prepare do
      Devise::RegistrationsController.layout('curate_nd/1_column')
    end

    config.manifest_url_generator = ->(id:) { sprintf("https://presentation-iiif.library.nd.edu/%s/manifest/index.json", id.to_s) }

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.generators do |g|
      g.test_framework :rspec, :spec => true, :fixture => false
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end

    SMTP_CONFIG = YAML.load_file(Rails.root.join("config/smtp_config.yml")).fetch(Rails.env)

    config.action_mailer.delivery_method = SMTP_CONFIG['smtp_delivery_method'].to_sym
    config.action_mailer.smtp_settings = {
      address:              SMTP_CONFIG['smtp_host'],
      port:                 SMTP_CONFIG['smtp_port'],
      domain:               SMTP_CONFIG['smtp_domain'],
      user_name:            SMTP_CONFIG['smtp_user_name'],
      password:             SMTP_CONFIG['smtp_password'],
      authentication:       SMTP_CONFIG['smtp_authentication_type'],
      enable_starttls_auto: SMTP_CONFIG['smtp_enable_starttls_auto']
    }

    adapter = Flipper::Adapters::Memory.new
    flipper = Flipper.new(adapter)
    config.use_proxy_for_download= flipper[:use_proxy_for_download]

  end
end
