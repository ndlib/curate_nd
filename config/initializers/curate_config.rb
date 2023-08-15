Curate.configure do |config|
  # Injected via `rails g curate:work SeniorThesis`

  # ***************************************************************************************************************************************
  # ***************************************************************************************************************************************
  #
  # Note: These are all of the curation concerns. They are a superset of what can be self-deposited.
  # To remove something from self-deposit, see WorkTypePolicy (./app/models/work_type_policy.rb)
  #
  # ***************************************************************************************************************************************
  # ***************************************************************************************************************************************
  config.register_curation_concern :senior_thesis
  config.register_curation_concern :finding_aid
  config.register_curation_concern :etd
  config.register_curation_concern :dataset
  config.register_curation_concern :article
  config.register_curation_concern :audio
  config.register_curation_concern :video
  config.register_curation_concern :image
  config.register_curation_concern :document
  config.register_curation_concern :catholic_document
  config.register_curation_concern :patent
  config.register_curation_concern :osf_archive
  config.register_curation_concern :dissertation

  config.application_root_url = Rails.configuration.application_root_url

  config.fedora_integrity_message_delivery = ->(options) do
    begin
      pid = options.fetch(:pid) || "PID unknown"
      message = options.fetch(:message)|| "Message Missing"
      exception = Exception.new("Problem with: "+pid+","+message)
    end
  end
end

# Add :has_profile predicate for use in ActiveModel (RELS-EXT) relationships
ActiveFedora::Predicates.set_predicates("http://projecthydra.org/ns/relations#"=>{:has_profile => "hasProfile"})

require 'object_relationship_reindexing_worker'
require 'all_relationships_reindexing_worker'

Curate::Indexer.configure do |config|
  require 'curate/library_collection_indexing_adapter'
  config.adapter = Curate::LibraryCollectionIndexingAdapter
end
