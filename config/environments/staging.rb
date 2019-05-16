CurateNd::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Expands the lines which load the assets
  config.assets.debug = true

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( modernizr.js rich_text_editor.js simplemde.min.css )

  config.application_root_url = "https://localhost"

  config.fits_path = '/opt/fits/current/fits.sh'

  begin
    # Why the explicit require? Because the headless workers of pre-production
    # are not explicitly requiring clamav; This is because the web application
    # portion of pre-production doesn't know about clamav. Instead of mixing
    # environments, we are going to let the workers fail.
    require 'clamav'
    ClamAV.instance.loaddb
    Curate.configuration.default_antivirus_instance = lambda {|file_path|
      ClamAV.instance.scanfile(file_path)
    }
  rescue LoadError => e
    logger.error("#{e.class}: #{e}")
  end

  config.use_proxy_for_download.enable

  config.logstash = [
    {
      type: :file,
      path: "log/#{Rails.env}.log"
    }
  ]

  config.log_level = :info
end
