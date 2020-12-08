Resque.inline = true
CurateNd::Application.configure do
  config.fits_path = 'fits.sh'

  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = true

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.application_root_url = "http://0.0.0.0"
  config.default_oai_limit = 1

  # for iiif image viewer
  config.manifest_viewer = "https://viewer-iiif.library.nd.edu/universalviewer/index.html#?manifest="
  config.manifest_builder_url = "https://presentation-iiif.library.nd.edu/"

  Curate.configuration.default_antivirus_instance = lambda {|file_path|
    AntiVirusScanner::NO_VIRUS_FOUND_RETURN_VALUE
  }

  if ENV['TRAVIS']
    Curate.configuration.characterization_runner = lambda { |file_path|
      Rails.root.join('spec/support/files/default_fits_output.xml').read
    }
  end

end
