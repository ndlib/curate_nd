Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environment = Rails.env
  config.release = Curate.configuration.build_identifier
  config.excluded_exceptions += ['ActiveFedora::RecordNotFound', 'ActiveRecord::RecordNotFound', 'ActiveFedora::ObjectNotFoundError', 'ActiveFedora::ActiveObjectNotFoundError', 'URI::InvalidComponentError', 'ActionController::UnknownFormat']
end