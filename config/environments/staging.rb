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
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( modernizr.js rich_text_editor.js simplemde.min.css )

  config.application_root_url = "https://localhost"

  # for iiif image viewer
  config.manifest_viewer = "https://viewer-iiif.library.nd.edu/universalviewer/index.html#?manifest="
  config.manifest_builder_url = "https://presentation-iiif.library.nd.edu/"

  config.fits_path = '/opt/fits/current/fits.sh'
  config.default_oai_limit = 100

  begin
    # Why the explicit require? Because the headless workers of pre-production
    # are not explicitly requiring clamav; This is because the web application
    # portion of pre-production doesn't know about clamav. Instead of mixing
    # environments, we are going to let the workers fail.
    require 'clamby'
    Clamby.configure({
      :check => false,
      :daemonize => false,
      :error_clamscan_missing => true,
      :error_clamscan_client_error => false,
      :error_file_missing => true,
      :error_file_virus => false,
      :output_level => 'medium', # one of 'off', 'low', 'medium', 'high'
      :executable_path_clamscan => 'clamscan',
      :executable_path_clamdscan => 'clamdscan',
      :executable_path_freshclam => 'freshclam',
      })
    Curate.configuration.default_antivirus_instance = lambda {|file_path|
      Clamby.safe?(file_path)
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
