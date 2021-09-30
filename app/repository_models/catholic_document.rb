class CatholicDocument < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::WithJsonMapper
  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  has_metadata 'descMetadata', type: CatholicDocumentDatastream

  class_attribute :human_readable_short_description
  self.human_readable_short_description = 'Deposit any Catholic document.'

  # we have not specified a preferred format
  def preferred_file_format
    ''
  end

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: {
      presence: { message: 'Your Catholic document must have a title.' }
    }
  attribute :alternate_title,
    datastream: :descMetadata, multiple: true
  attribute :abstract,
    datastream: :descMetadata, multiple: false
  attribute :creator,
    datastream: :descMetadata, multiple: true,
    label: 'Author'
  attribute :issued_by,
    datastream: :descMetadata, multiple: true,
    hint: 'The person, family, corporate body, or other entity who issued the work.'
  attribute :promulgated_by,
    datastream: :descMetadata, multiple: true,
    label: 'Promulgated By',
    hint: 'The person, family, corporate body, or entity who promulgated the work.'
  # This is weird, but the date issued doesn't have to do with Publication for this, so this is just a labeling thing. The dc:issued will be the actual publication date...
  attribute :date_issued,
    datastream: :descMetadata, multiple: false,
    label: 'Date Published',
    validates: {
      allow_blank: true,
      format: {
        with: /\A(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})\Z/,
        message: 'Must be a four-digit year or year-month/year-month-day formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
      }
    }
  # It's a labeling thing.
  attribute :date,
    datastream: :descMetadata, multiple: false,
    label: 'Date Issued',
    validates: {
      allow_blank: true,
      format: {
        with: /\A(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})\Z/,
        message: 'Must be a four-digit year or year-month/year-month-day formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
      }
    }
  attribute :promulgated_date,
    datastream: :descMetadata, multiple: false,
    label: 'Date Promulgated',
    validates: {
      allow_blank: true,
      format: {
        with: /\A(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})\Z/,
        message: 'Must be a four-digit year or year-month/year-month-day formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
      }
    }
  attribute :subject,
    label: 'Subjects',
    datastream: :descMetadata, multiple: true
  attribute :extent,
    label: 'Number of Pages',
    datastream: :descMetadata, multiple: false
  attribute :spatial_coverage,
    datastream: :descMetadata, multiple: true
  attribute :temporal_coverage,
    datastream: :descMetadata, multiple: true
  attribute :language,
    datastream: :descMetadata, multiple: true
  attribute :type,
    datastream: :descMetadata, multiple: false
  attribute :repository_name,
    datastream: :descMetadata, multiple: true
  attribute :publisher,
    datastream: :descMetadata, multiple: true
  attribute :source,
    datastream: :descMetadata, multiple: true
  attribute :rights_holder,
    datastream: :descMetadata, multiple: false,
    label: 'Rights Holder',
    hint: 'A statement about entities who own the rights to the material along with any additional information about contact or use.'
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :copyright_date,
    datastream: :descMetadata, multiple: false,
    validates: {
      allow_blank: true,
      format: {
        with: /\d{4}/,
        message: 'must be a four-digit year'
      }
    }
  attribute :requires,
    datastream: :descMetadata, multiple: true
  attribute :administrative_unit,
    datastream: :descMetadata, multiple: true,
    label: "Departments and Units",
    hint: "Departments and Units that creator belong to."
  attribute :rights,
      datastream: :descMetadata, multiple: false,
      default: "All rights reserved",
      validates: { presence: { message: 'You must select a license for your work.' } }
  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false
  attribute :date_modified,
    datastream: :descMetadata, multiple: false
  attribute :alephIdentifier,
    datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        aleph_identifier: true
    }
  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."
end
