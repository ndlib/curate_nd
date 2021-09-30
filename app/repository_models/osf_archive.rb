# Models two "types" of OSF Archives:
#
# * OSF Project
# * OSF Registration
#
# The OSF Registration is a "snapshot" of an OSF Project. The Registration has a URL
# separate from the OSF Project; It points back to the OSF Project. In theory, if
# we ingest the same OSF Registration we will have the same information; In practice,
# some of the data for the registration may point to external sources that have changed
# between ingests of that OSF Registration.
#
# The OSF Project is a living/mutable source. It represents the current state of the project.
# When we ingest an OSF Project, that current state is captured.
class OsfArchive < ActiveFedora::Base
  include ActiveModel::Validations
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  include CurationConcern::WithJsonMapper

  before_validation :set_initial_values, on: :create

  belongs_to :previousVersion, property: :previousVersion, class_name: "OsfArchive"

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Change me."

  def self.human_readable_type
    'OSF Archive'
  end

  # These are included as convenience for developers.
  SOLR_KEY_OSF_PROJECT_IDENTIFIER = 'desc_metadata__osf_project_identifier_ssi'.freeze
  SOLR_KEY_ARCHIVED_DATE = 'desc_metadata__date_archived_dtsi'.freeze
  SOLR_KEY_SOURCE = 'desc_metadata__source_ssi'.freeze

  # Retrieve all archived versions of the source project (including registrations)
  # in date_archived descending order.
  #
  # @return [Array<OsfArchive>]
  # @see ./spec/repository_models/osf_archive_spec.rb
  def archived_versions_of_source_project
    @archived_versions_of_source_project ||= begin
      conditions = { SOLR_KEY_OSF_PROJECT_IDENTIFIER => osf_project_identifier }
      options = { sort: "#{SOLR_KEY_ARCHIVED_DATE} desc" }
      solr_results = self.class.find_with_conditions(conditions, options)
      ActiveFedora::SolrService.reify_solr_results(solr_results, load_from_solr: true)
    end
  end

  def set_initial_values
    self.date_modified = Date.today
    self.date_archived ||= Date.today
    determine_type_and_osf_project_identifier
  end
  private :set_initial_values

  def determine_type_and_osf_project_identifier
    if osf_project_identifier.present?
      if osf_project_identifier == osf_source_slug
        self.type = "OSF Project"
      else
        self.type = "OSF Registration"
      end
    else
      if osf_source_slug.present?
        self.osf_project_identifier = osf_source_slug
        self.type = "OSF Project"
      end
    end
  end
  private :determine_type_and_osf_project_identifier

  def osf_source_slug
    self.source.to_s.split('/').last
  end

  has_metadata 'descMetadata', type: OsfArchiveDatastream

  attribute :affiliation,
    datastream: :descMetadata,
    hint: "Creator's Affiliation to the Institution.",
    multiple: false

  attribute :creator,
    datastream: :descMetadata, multiple: true

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Your archive must have a title.' }}

  attribute :source,
    datastream: :descMetadata, multiple: false,
    label: 'Original OSF URL',
    validates: {
      format: {
      with: URI::regexp(%w(http https ftp)),
      message: 'must be a valid URL.'
      }
    }

  attribute :osf_project_identifier,
    datastream: :descMetadata, multiple: false,
    label: 'OSF Project Identifier'

  attribute :subject,
    datastream: :descMetadata, multiple: true

  attribute :type,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Archive type is required.' }}

  attribute :language,
    datastream: :descMetadata, multiple: true

  attribute :administrative_unit,
    datastream: :descMetadata, multiple: true,
    label: "Departments and Units",
    hint: "Departments and Units that creator belong to."

  attribute :description,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Your archive must have a description.' }}

  attribute :date_created,
    datastream: :descMetadata, multiple: false,
    default: lambda { Date.today.to_s("%Y-%m-%d") },
    label: "Date object was created in the OSF",
    validates: {presence: { message: 'Created date is required.' }}

  attribute :date_modified,
    datastream: :descMetadata, multiple: false,
    validates: {presence: { message: 'Modified date is required.' }}

  attribute :date_archived,
    datastream: :descMetadata, multiple: false,
    label: "Date Archived",
    validates: {presence: { message: 'Archived date is required.' }}

  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }

  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false

  attribute :alephIdentifier, datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        aleph_identifier: true
    }
end
