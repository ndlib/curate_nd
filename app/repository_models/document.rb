class Document < ActiveFedora::Base
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

  has_metadata 'descMetadata', type: DocumentDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  self.human_readable_short_description = 'Deposit any text-based document (other than an article).'

  self.indefinite_article = 'an'
  self.contributor_label = 'Author'

  DOCUMENT_TYPES = [
    'Book Chapter',
    'Book',
    'Brief',
    'Brochure',
    'Case Study',
    'Document',
    'Letter',
    'Manuscript',
    'Newsletter',
    'OpenCourseWare',
    'Pamphlet',
    'Presentation',
    'Press Release',
    'Program',
    'Report',
    'Software',
    'White Paper'
  ].freeze

  def self.valid_types
    DOCUMENT_TYPES
  end

  def human_readable_type
    self.type.present? ? type.titleize :  self.class.human_readable_type
  end

  # base attributes
  attribute :type,                       datastream: :descMetadata, multiple: false,
            validates: {
              inclusion: {
                in: Document.valid_types,
                allow_blank: true
              }
            }
  attribute :title,
      datastream: :descMetadata, multiple: false,
      label: "Title of your Article",
      validates: {presence: { message: 'Your work must have a title.' }}
  attribute :abstract,                   datastream: :descMetadata, multiple: false
  attribute :affiliation,                datastream: :descMetadata, multiple: false,
            hint: 'Creator’s Affiliation to the Institution.'
  attribute :administrative_unit,
      datastream: :descMetadata, multiple: true,
      label: "Departments and Units",
      hint: "Departments and Units that creator belong to."

  attribute :date_created,               datastream: :descMetadata, multiple: false,
      default: lambda { Date.today.to_s('%Y-%m-%d') }
  attribute :publisher,                  datastream: :descMetadata, multiple: true
  attribute :subject,                    datastream: :descMetadata, multiple: true
  attribute :source,                     datastream: :descMetadata, multiple: true
  attribute :relation,                   datastream: :descMetadata, multiple: true,
            validates: {
                allow_blank: true,
                format: {
                    with: URI::regexp(%w(http https ftp)),
                    message: 'must be a valid URL.'
                }
            }
  attribute :language,                   datastream: :descMetadata, multiple: true
  attribute :temporal_coverage,          datastream: :descMetadata, multiple: true
  attribute :spatial_coverage,           datastream: :descMetadata, multiple: true
  attribute :size,                       datastream: :descMetadata, multiple: true
  attribute :requires,                   datastream: :descMetadata, multiple: true
  attribute :repository_name,            datastream: :descMetadata, multiple: true
  attribute :collection_name,            datastream: :descMetadata, multiple: true
  attribute :contributor_institution,    datastream: :descMetadata, multiple: true
  attribute :recommended_citation,       datastream: :descMetadata, multiple: true
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }

  attribute :date_uploaded,              datastream: :descMetadata, multiple: false
  attribute :date_modified,              datastream: :descMetadata, multiple: false

  # @book attributes
  attribute :alternate_title,            datastream: :descMetadata, multiple: true
  attribute :author,                     datastream: :descMetadata, multiple: true
  attribute :coauthor,                   datastream: :descMetadata, multiple: true
  attribute :editor,                     datastream: :descMetadata, multiple: true
  attribute :contributing_editor,        datastream: :descMetadata, multiple: true
  attribute :artist,                     datastream: :descMetadata, multiple: true
  attribute :contributing_artist,        datastream: :descMetadata, multiple: true
  attribute :illustrator,                datastream: :descMetadata, multiple: true
  attribute :contributing_illustrator,   datastream: :descMetadata, multiple: true
  attribute :photographer,               datastream: :descMetadata, multiple: true
  attribute :contributing_photographer,  datastream: :descMetadata, multiple: true
  attribute :creator,                    datastream: :descMetadata, multiple: true
  attribute :contributor,                datastream: :descMetadata, multiple: true
  attribute :copyright_date,             datastream: :descMetadata, multiple: false,
            validates: {
              allow_blank: true,
              format: {
                with: /\d{4}/,
                message: 'must be a four-digit year'
              }
            }
  attribute :table_of_contents,          datastream: :descMetadata, multiple: false
  attribute :extent,                     datastream: :descMetadata, multiple: true
  attribute :isbn,                       datastream: :descMetadata, multiple: true,
            validates: {
              allow_blank: true,
              isbn: {}
            }
  attribute :local_identifier,           datastream: :descMetadata, multiple: true
  attribute :publication_date,           datastream: :descMetadata, multiple: false,
            validates: {
              allow_blank: true,
              format: {
                with: /\A(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})\Z/,
                message: 'Must be a four-digit year or year-month/year-month-day formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
              }
            }
  attribute :edition,                    datastream: :descMetadata, multiple: false
  attribute :lc_subject,                 datastream: :descMetadata, multiple: true

  # @program attributes
  attribute :event_speaker,
    datastream: :descMetadata, multiple: true,
    label: "Speaker",
    hint: "This property defines the speaker(s) at an event."

  # other attributes

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

  # apparently unused(?)
  attribute :format,                     datastream: :descMetadata, multiple: false
  attribute :organization,               datastream: :descMetadata, multiple: true,
            label: 'School & Department',
            hint: 'School and Department that creator belong to.'
  attribute :alephIdentifier,         datastream: :descMetadata, multiple: true,
            validates: {
                allow_blank: true,
                aleph_identifier: true
            }
end
