#require 'datastreams/properties_datastream'
#require_relative './generic_file'
require 'active_fedora/registered_attributes'

class SeniorThesis < ActiveFedora::Base
  include ActiveFedora::RegisteredAttributes
  include ActiveModel::Validations
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  include CurationConcern::WithJsonMapper

  self.human_readable_short_description = "PDFs and other Documents for your Senior Thesis"

  has_metadata name: "descMetadata", type: SeniorThesisRdfDatastream, control_group: 'M'

  attribute :title,
    datastream: :descMetadata, multiple: false,
    label: "Title of your Senior Thesis",
    validates: { presence: { message: 'Your must have a title.' } }
  attribute :creator,
    datastream: :descMetadata, multiple: true,
    label: "Author",
    hint: "Enter your preferred name",
    writer: :parse_person_names,
    reader: :parse_person_names,
    validates: { multi_value_presence: { message: "You must have an author."} }
  attribute :description,
    label: "Abstract or Summary of Senior Thesis",
    datastream: :descMetadata, multiple: false
  attribute :date_created,
    default: lambda { Date.today.to_s("%Y-%m-%d") },
    label: "When did you finish your Senior Thesis",
    hint: "This does not need to be exact, but your best guess.",
    datastream: :descMetadata, multiple: false
  attribute :advisor,
    datastream: :descMetadata, multiple: true,
    label: 'Advisor(s)',
    writer: :parse_person_names,
    reader: :parse_person_names
  attribute :contributor,
    datastream: :descMetadata, multiple: true,
    label: "Contributing Author(s)",
    hint: "Who else played a non-primary role in the creation of your Senior Thesis.",
    writer: :parse_person_names,
    reader: :parse_person_names
  attribute :subject,
    label: "Keyword(s) or phrase(s)",
    hint: "What words or phrases would be helpful for someone searching for your Senior Thesis",
    datastream: :descMetadata, multiple: true
  attribute :bibliographic_citation,
    hint: "Recommended Bibliographic Citation for referencing your Senior Thesis.",
    datastream: :descMetadata, multiple: true
  attribute :language,
    hint: "What is the language(s) in which you wrote your work?",
    default: ['English'],
    datastream: :descMetadata, multiple: true
  attribute :administrative_unit,
    datastream: :descMetadata, multiple: true,
    label: "Departments and Units",
    hint: "Departments and Units that creator belong to."
  attribute :publisher,
    default: ["University of Notre Dame"],
    datastream: :descMetadata, multiple: true
  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :visibility,
    skip_accessor: true,
    multiple: false,
    default: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
  validates: {
    inclusion: {
      in: ->(senior_thesis) {
        [
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO,
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED,
          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        ]
      },
      allow_nil: true
    }
  }
  attribute :created,
    datastream: :descMetadata, multiple: false
  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false
  attribute :date_modified,
    datastream: :descMetadata, multiple: false
  attribute :content_format,
    datastream: :descMetadata, multiple: false

  attribute :source,
    datastream: :descMetadata, multiple: true
  attribute :extent,
    datastream: :descMetadata, multiple: true
  attribute :requires,
    datastream: :descMetadata, multiple: true
  attribute :resource_type,
    label: "Archived Content Type",
    datastream: :descMetadata, multiple: false
  attribute :relation,
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

  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

  def authors_for_citation
    creator | advisor | contributor
  end

  def citation
    @citation ||= Citation.new(self)
  end

  private
  def parse_person_names(values)
    Array(values).each_with_object([]) {|value, collector|
      Namae.parse(value).each {|name|
        collector << normalize_contributor(name)
      }
    }
  end

  def normalize_contributor(name)
    [
      name.appellation,
      name.title,
      name.given,
      name.dropping_particle,
      name.nick,
      name.particle,
      name.family,
      name.suffix
    ].flatten.compact.join(" ")
  end

end
