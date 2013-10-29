Resque.inline = true
CurateNd::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = true

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
  config.assets.precompile += %w( modernizr.js )

  config.application_root_url = "http://localhost"

  if ENV['FULL_STACK']
    require 'clamav'
    ClamAV.instance.loaddb
    Curate.configuration.default_antivirus_instance = lambda {|file_path|
      ClamAV.instance.scanfile(file_path)
    }
  else
    Curate.configuration.default_antivirus_instance = lambda {|file_path|
      AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE
    }
    Curate.configuration.characterization_runner = lambda { |file_path|
      Rails.root.join('spec/support/files/default_fits_output.xml').read
    }
  end

end
