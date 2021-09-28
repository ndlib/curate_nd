class Video < ActiveFedora::Base
  include ActiveModel::Validations
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::WithJsonMapper
  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  has_metadata "descMetadata", type: VideoDatastream

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit a video recording."

  # we have not specified a preferred format
  def preferred_file_format
    ''
  end

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your article must have a title.' } }
  attribute :description,
    datastream: :descMetadata, multiple: false
  attribute :alternate_title,
    datastream: :descMetadata, multiple: true
  attribute :performer,
    datastream: :descMetadata, multiple: true,
    hint: "One of the work’s performers, whether singer, speaker, voice actor, musician, or other role."
  attribute :director,
    datastream: :descMetadata, multiple: true,
    hint: "A person responsible for the general management and supervision of a filmed performance, a radio or television program, etc."
  attribute :screenwriter,
    datastream: :descMetadata, multiple: true,
    hint: "An author of a screenplay, script, or scene."
  attribute :interviewer,
    datastream: :descMetadata, multiple: true,
    hint: "An entity responsible for the creation of a resource by acting as interviewer or host."
  attribute :interviewee,
    datastream: :descMetadata, multiple: true,
    hint: "An entity responsible for elements of the resource by responding to an interviewer or host."
  attribute :speaker,
    datastream: :descMetadata, multiple: true,
    hint: "A performer contributing to a resource by speaking words, such as a lecture, speech, etc."
  attribute :producer,
    datastream: :descMetadata, multiple: true,
    hint: "The producer of a work."
  attribute :production_company,
    datastream: :descMetadata, multiple: true,
    hint: "An organization that is responsible for financial, technical, and organizational management of a production for stage, screen, audio recording, television, webcast, etc."
  attribute :creator,
    datastream: :descMetadata, multiple: true
  attribute :contributor,
    datastream: :descMetadata, multiple: true
  attribute :duration,
    datastream: :descMetadata, multiple: false,
    hint: "The resource’s duration formatted as HH:MM:SS. For purposes of standardization, please include hours as “00” even if the resource is less than an hour long."
  attribute :subject,
    datastream: :descMetadata, multiple: true
  attribute :genre,
    datastream: :descMetadata, multiple: true,
    hint: "The genre(s) to which the video object belongs."
  attribute :language,
    datastream: :descMetadata, multiple: true
  attribute :is_part_of,
    datastream: :descMetadata, multiple: true,
    hint: "The larger work, e.g. series, of which this video object is a part. May be a full citation, a URL, or simply a name."
  attribute :date_created,
    datastream: :descMetadata, multiple: false
  attribute :publisher,
    datastream: :descMetadata, multiple: true
  attribute :publication_date,
    datastream: :descMetadata, multiple: false,
    validates: {
      allow_blank: true,
      format: {
        with: /\A(\d{4}-\d{2}-\d{2}|\d{4}-\d{2}|\d{4})\Z/,
        message: 'The year, year and month, or date on which this video object was published. Formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
      }
    }
    attribute :administrative_unit,
      datastream: :descMetadata, multiple: true,
      label: "Departments and Units",
      hint: "Departments and Units that creator belong to."
  attribute :source,
    datastream: :descMetadata, multiple: true
  attribute :relation,
    hint: "Link to External Content",
    datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        format: {
            with: URI::regexp(%w(http https ftp)),
            message: 'must be a valid URL.'
        }
    }
  attribute :alephIdentifier,
    datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        aleph_identifier: true
    }
  attribute :affiliation,
    datastream: :descMetadata, multiple: false,
    hint: "Creator's Affiliation to the Institution."
  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false
  attribute :date_modified,
    datastream: :descMetadata, multiple: false
  attribute :rights,
      datastream: :descMetadata, multiple: false,
      default: "All rights reserved",
      validates: { presence: { message: 'You must select a license for your work.' } }
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."
end
