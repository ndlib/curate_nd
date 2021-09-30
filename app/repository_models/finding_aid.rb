require 'active_fedora/registered_attributes'
class FindingAid < ActiveFedora::Base
  include ActiveModel::Validations
  include ActiveFedora::RegisteredAttributes
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedContributors
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include CurationConcern::WithJsonMapper

  before_create :set_visibility_to_open_access

  has_metadata "descMetadata", type: FindingAidRdfDatastream, control_group: 'M'

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit a EAD Finding Aid."

  attribute :title,
    datastream: :descMetadata, multiple: false,
    label: "Title of your Finding Aid",
    validates: { presence: { message: 'Your Finding Aid must have a title.' } }
  attribute :creator, datastream: :descMetadata, multiple: true, validates: { multi_value_presence: true }
  attribute :contributor,
    datastream: :descMetadata, multiple: true,
    label: "Contributing Author(s)"
  attribute :abstract,
    label: "Abstract or Summary of the Finding Aid",
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your Finding Aid must have an abstract.' } }
  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."
  attribute :administrative_unit,
    datastream: :descMetadata, multiple: true,
    label: "Departments and Units",
    hint: "Departments and Units that creator belong to."
  attribute :basic_identifier, datastream: :descMetadata, multiple: false
  attribute :date_uploaded,
    default: lambda { Date.today.to_s("%Y-%m-%d") }
  attribute :date_modified,
    default: lambda { Date.today.to_s("%Y-%m-%d") }
  attribute :rights,
    datastream: :descMetadata, multiple: false,
    default: "All rights reserved",
    validates: { presence: { message: 'You must select a license for your work.' } }
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false
  attribute :source,
    datastream: :descMetadata, multiple: true
  attribute :relation,
    datastream: :descMetadata, multiple: true
  attribute :alephIdentifier, datastream: :descMetadata, multiple: true,
    validates: {
      allow_blank: true,
      aleph_identifier: true
    }


  private
  def set_visibility_to_open_access
    self.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

end
