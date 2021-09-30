class Audio < ActiveFedora::Base
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

  has_metadata "descMetadata", type: AudioDatastream

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit an audio recording."

  self.indefinite_article = 'an'
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
  attribute :composer,
    datastream: :descMetadata, multiple: true,
    hint: "The composer of a work."
  attribute :conductor,
    datastream: :descMetadata, multiple: true,
    hint: "The conductor of a work."
  attribute :work_author,
    datastream: :descMetadata, multiple: true,
    hint: "The author of text or other material used in the work. Use Composer for works of music."
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
    hint: "The genre(s) to which the audio object belongs."
  attribute :language,
    datastream: :descMetadata, multiple: true
  attribute :is_part_of,
    datastream: :descMetadata, multiple: true,
    hint: "The larger work, e.g. album, symphony, podcast, of which this audio object is a part. May be a full citation, a URL, or simply a name."
  attribute :original_media_source,
    datastream: :descMetadata, multiple: true,
    hint: "Information about the specific location from which an audio track derives, such as “Disc 2, Track 13.” Information about the larger work should be included in “Part of.”"
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
        message: 'The year, year and month, or date on which this audio object was published. Formatted as YYYY or YYYY-MM or YYYY-MM-DD.'
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
