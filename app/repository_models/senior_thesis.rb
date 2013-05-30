#require 'datastreams/properties_datastream'
#require_relative './generic_file'
require 'curation_concern/model'
require 'active_fedora/delegate_attributes'

class SeniorThesis < ActiveFedora::Base
  include CurationConcern::Model
  include CurationConcern::WithGenericFiles
  include CurationConcern::Embargoable
  include CurationConcern::WithAccessRight
  include ActiveFedora::DelegateAttributes

  self.human_readable_short_description = "PDFs and other Documents for your Senior Thesis"

  has_metadata name: "descMetadata", type: SeniorThesisMetadataDatastream, control_group: 'M'

  attribute :title,
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'Your must have a title.' } }
  attribute :created,
    datastream: :descMetadata, multiple: false
  attribute :description,
    datastream: :descMetadata, multiple: false
  attribute :date_uploaded,
    datastream: :descMetadata, multiple: false
  attribute :date_modified,
    datastream: :descMetadata, multiple: false
  attribute :available,
    datastream: :descMetadata, multiple: false
  attribute :archived_object_type,
    datastream: :descMetadata, multiple: false
  attribute :content_format,
    datastream: :descMetadata, multiple: false
  attribute :identifier,
    datastream: :descMetadata, multiple: false
  attribute :rights,
    datastream: :descMetadata, multiple: false,
    validates: { presence: { message: 'You must select a license for your work.' } }
  attribute :date_created,
    datastream: :descMetadata, multiple: false

  attribute :publisher,
    datastream: :descMetadata, multiple: true
  attribute :bibliographic_citation,
    datastream: :descMetadata, multiple: true
  attribute :source,
    datastream: :descMetadata, multiple: true
  attribute :language,
    datastream: :descMetadata, multiple: true
  attribute :extent,
    datastream: :descMetadata, multiple: true
  attribute :requires,
    datastream: :descMetadata, multiple: true
  attribute :subject,
    datastream: :descMetadata, multiple: true

  attribute :creator,
    datastream: :descMetadata, multiple: true,
    writer: :parse_person_names,
    reader: :parse_person_names,
    validates: { presence: { message: "You must have an author."} }

  attribute :contributor,
    datastream: :descMetadata, multiple: true,
    writer: :parse_person_names,
    reader: :parse_person_names

  attribute :advisor,
    datastream: :descMetadata, multiple: true,
    writer: :parse_person_names,
    reader: :parse_person_names

  attr_accessor :files, :assign_doi

  def doi_url
    File.join(Rails.configuration.doi_url, self.identifier)
  end

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
