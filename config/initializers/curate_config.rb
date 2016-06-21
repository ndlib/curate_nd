Curate.configure do |config|
  # Injected via `rails g curate:work SeniorThesis`
  config.register_curation_concern :senior_thesis
  config.register_curation_concern :finding_aid
  config.register_curation_concern :etd
  config.register_curation_concern :dataset
  config.register_curation_concern :article
  config.register_curation_concern :image
  config.register_curation_concern :document
  config.register_curation_concern :etd
  config.register_curation_concern :patent

  config.application_root_url = Rails.configuration.application_root_url

  config.fedora_integrity_message_delivery = ->(options) do
    begin
      pid = options.fetch(:pid) || "PID unknown"
      message = options.fetch(:message)|| "Message Missing"
      exception = Exception.new("Problem with: "+pid+","+message)
      Harbinger.call(reporters: [exception], channels: [:database, :logger])
    rescue StandardError => e
      logger.error("Unable to notify Harbinger. #{e.class}: #{e}\n#{e.backtrace.join("\n")} \n Logging exception. #{exception.message}")
    end
  end
end

# Add :has_profile predicate for use in ActiveModel (RELS-EXT) relationships
ActiveFedora::Predicates.set_predicates("http://projecthydra.org/ns/relations#"=>{:has_profile => "hasProfile"})

Curate::Indexer.configure do |config|
  require 'curate/library_collection_indexing_adapter'
  config.adapter = Curate::LibraryCollectionIndexingAdapter
end
