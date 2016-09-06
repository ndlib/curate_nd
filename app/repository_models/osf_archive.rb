class OsfArchive < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  after_initialize :set_default_values

  before_validation :set_initial_values, on: :create

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Change me."

  def set_default_values
    self.type = 'OSF Archive'
  end
  private :set_default_values

  def set_initial_values
    self.date_modified = Date.today
    self.date_archived = Date.today
  end
  private :set_initial_values

  has_metadata 'descMetadata', type: OsfArchiveDatastream

  attribute :administrative_unit,
    datastream: :descMetadata, multiple: true,
    label: "Departments and Units",
    hint: "Departments and Units that creator belong to."

  attribute :affiliation,
    datastream: :descMetadata,
    hint: "Creator's Affiliation to the Institution.",
    multiple: false

  attribute :creator,
    datastream: :descMetadata, multiple: true

  attribute :identifier,
    datastream: :descMetadata, multiple: false,
    editable: false

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Your archive must have a title.' }}

  attribute :source,
    datastream: :descMetadata, multiple: false,
    label: 'Original OSF Project',
    validates: {
      allow_blank: true,
        format: {
        with: URI::regexp(%w(http https ftp)),
        message: 'must be a valid URL.'
        }
    }

  attribute :subject,
    datastream: :descMetadata, multiple: true

  attribute :type,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Archive type is required.' }}

  attribute :language,
    datastream: :descMetadata, multiple: true

  attribute :department,
    datastream: :descMetadata, multiple: true,
    label: "Department",
    validates: {presence: { message: 'Department is required.' }}

  attribute :description,
    datastream: :descMetadata, multiple: true,
    validates: {presence: { message: 'Your archive must have a description.' }}

  attribute :date_created,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Created date is required.' }}

  attribute :date_modified,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Modified date is required.' }}

  attribute :date_archived,
    datastream: :descMetadata, multiple: false,
    label: "Date Archived",
    validates: {presence: { message: 'Archived date is required.' }}

  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false

  attribute :rights,
    datastream: :descMetadata, multiple: true

  attribute :doi,
    datastream: :descMetadata, multiple: true
end
