class Dataset < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include CurationConcern::WithJsonMapper
  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: DatasetMetadataDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "One or more files related to your research."

  attribute :title, datastream: :descMetadata,
            multiple: false,
            validates: {presence: { message: 'Your dataset must have a title.' }}

  attribute :rights, datastream: :descMetadata,
            default: "All rights reserved",
            multiple: false,
            validates: {presence: { message: 'You must select a license for your dataset.' }}
  attribute :contributor, datastream: :descMetadata, multiple: true
  attribute :affiliation,datastream: :descMetadata, hint: "Creator's Affiliation to the Institution.", multiple: false
  attribute :organization,
            datastream: :descMetadata, multiple: true,
            label: "Organization",
            hint: "Organizations which creators belong to."
  attribute :administrative_unit,
            datastream: :descMetadata, multiple: true,
            label: "School & Department",
            hint: "School and Department that creator belong to."
  attribute :date_created,            datastream: :descMetadata, multiple: false, default: lambda { Date.today.to_s("%Y-%m-%d") }
  attribute :date_uploaded,           datastream: :descMetadata, multiple: false
  attribute :date_modified,           datastream: :descMetadata, multiple: false
  attribute :description,             datastream: :descMetadata, multiple: false
  attribute :methodology,             datastream: :descMetadata, multiple: false
  attribute :data_processing,         datastream: :descMetadata, multiple: false
  attribute :file_structure,          datastream: :descMetadata, multiple: false
  attribute :variable_list,           datastream: :descMetadata, multiple: false
  attribute :code_list,               datastream: :descMetadata, multiple: false
  attribute :temporal_coverage,       datastream: :descMetadata, multiple: true
  attribute :spatial_coverage,        datastream: :descMetadata, multiple: true
  attribute :creator,                 datastream: :descMetadata, multiple: true
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :publisher,               datastream: :descMetadata, multiple: true
  attribute :contributor_institution, datastream: :descMetadata, multiple: true
  attribute :source,                  datastream: :descMetadata, multiple: true
  attribute :language,                datastream: :descMetadata, multiple: true
  attribute :subject,                 datastream: :descMetadata, multiple: true
  attribute :recommended_citation,    datastream: :descMetadata, multiple: true
  attribute :repository_name,         datastream: :descMetadata, multiple: true
  attribute :collection_name,         datastream: :descMetadata, multiple: true
  attribute :size,                    datastream: :descMetadata, multiple: true
  attribute :requires,                datastream: :descMetadata, multiple: true
  attribute :relation,                datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        format: {
            with: URI::regexp(%w(http https ftp)),
            message: 'must be a valid URL.'
        }
    }
  attribute :alephIdentifier, multiple: true,
    datastream: :descMetadata,
    validates: {
        allow_blank: true,
        aleph_identifier: true
    }

  attribute :files, multiple: true, form: {as: :file},
            hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
