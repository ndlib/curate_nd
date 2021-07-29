Resque.inline = true
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

  # Generate digests for assets URLs
  config.assets.digest = true

  # Do not compress assets
  config.assets.compress = false

  config.assets.compile = true

  # # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( modernizr.js rich_text_editor.js simplemde.min.css )

  # Expands the lines which load the assets
  config.assets.debug = ENV.fetch('ASSET_DEBUG', false)

  config.application_root_url = "http://localhost:3000"

  # for iiif image viewer
  config.manifest_viewer = "https://viewer-iiif.library.nd.edu/universalviewer/index.html#?manifest="
  config.manifest_builder_url = "https://presentation-iiif.library.nd.edu/"

  if ENV['FULL_STACK']
    # require 'clamav'
    # ClamAV.instance.loaddb
    # Curate.configuration.default_antivirus_instance = lambda {|file_path|
    #   ClamAV.instance.scanfile(file_path)
    # }
  else
    Curate.configuration.default_antivirus_instance = lambda {|file_path|
      AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE
    }
    Curate.configuration.characterization_runner = lambda { |file_path|
      Rails.root.join('spec/support/files/default_fits_output.xml').read
    }
  end

  # to run characterization, comment out the characterization_runner above, and
  # uncomment the line below, filling in the path to fits on your system.
  # config.fits_path = '/usr/local/bin/fits.sh'

  config.logger = Logger.new(STDOUT)
  config.default_oai_limit = 5

  # Uncomment to enable background jobs in development.
  # Note: you will also need to run `bundle exec rake resque:pool`
  #Resque.inline = false
end
