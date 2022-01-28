# NOTE: this is for documentation only. Nothing should inherit from GenericWork
class GenericWork < ActiveFedora::Base
  include ActiveModel::Validations
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

  has_metadata "descMetadata", type: GenericWorkRdfDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  attribute :title, datastream: :descMetadata,
    multiple: false,
    validates: {presence: { message: 'Your work must have a title.' }}

  attribute :rights, datastream: :descMetadata,
    multiple: false,
    default: Copyright.default_persisted_value,
    validates: {presence: { message: 'You must select a license for your work.' }}

  attribute :date_created,        datastream: :descMetadata, multiple: false
  attribute :description,    datastream: :descMetadata, multiple: false
  attribute :date_uploaded,  datastream: :descMetadata, multiple: false
  attribute :date_modified,  datastream: :descMetadata, multiple: false
  attribute :available,      datastream: :descMetadata, multiple: false
  attribute :creator,        datastream: :descMetadata, multiple: true
  attribute :affiliation,datastream: :descMetadata, hint: "Creator's Affiliation to the Institution.", multiple: false
  attribute :organization,
            datastream: :descMetadata, multiple: true,
            label: "Organization",
            hint: "Organizations which creators belong to."
  attribute :administrative_unit,
            datastream: :descMetadata, multiple: true,
            label: "Departments and Units",
            hint: "Departments and Units that creator belong to."
  attribute :content_format, datastream: :descMetadata, multiple: false

  attribute :contributor,            datastream: :descMetadata, multiple: true
  attribute :publisher,              datastream: :descMetadata, multiple: true
  attribute :bibliographic_citation, datastream: :descMetadata, multiple: true
  attribute :source,                 datastream: :descMetadata, multiple: true
  attribute :language,               datastream: :descMetadata, multiple: true
  attribute :extent,                 datastream: :descMetadata, multiple: true
  attribute :requires,               datastream: :descMetadata, multiple: true
  attribute :subject,                datastream: :descMetadata, multiple: true
  attribute :relation,               datastream: :descMetadata, multiple: true,
            validates: {
                allow_blank: true,
                format: {
                    with: URI::regexp(%w(http https ftp)),
                    message: 'must be a valid URL.'
                }
            }
  attribute :alephIdentifier,         datastream: :descMetadata, multiple: true,
    validates: {
      allow_blank: true,
      aleph_identifier: true
    }
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
