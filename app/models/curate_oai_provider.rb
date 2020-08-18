class CurateOaiProvider < OAI::Provider::Base
  repository_name "CurateOaiProvider"
  repository_url Curate.configuration.application_root_url
  record_prefix "oai"
  admin_email ENV.fetch('CURATE_HELP_NOTIFICATION_RECIPIENT')
  sample_id "und:123456789"
  register_format(CurationConcernProvider::Dcterms.instance)

  def initialize(controller:)
    super({ provider_context: :instance_based })
    self.model= CurationConcernProvider.new(controller: controller)
  end
end
