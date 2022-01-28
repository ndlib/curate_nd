class Etd < ActiveFedora::Base
  include ActiveModel::Validations
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithRecordEditors
  include CurationConcern::WithRecordViewers
  include CurationConcern::WithJsonMapper
  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: EtdMetadata

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  etd_label = human_readable_type

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit a master's thesis or dissertation."

  def self.human_readable_type
    'Thesis or Dissertation'
  end

  def human_readable_type
    degree.map(&:level).flatten.to_sentence
  end

  has_attributes :degree, :degree_attributes, datastream: :descMetadata, multiple: true
  has_attributes :contributor, :contributor_attributes, datastream: :descMetadata, multiple: true

  def build_degree
    descMetadata.degree = [EtdMetadata::Degree.new(RDF::Repository.new)]
  end

  def build_contributor
    descMetadata.contributor = [EtdMetadata::Contributor.new(RDF::Repository.new)]
  end

  def self.valid_degree_levels
    ControlledVocabularyService.labels_for_predicate_name(name: "degree_level")
  end

  def self.valid_degree_names
    ControlledVocabularyService.labels_for_predicate_name(name: "degree")
  end

  def self.valid_degree_disciplines
    ControlledVocabularyService.labels_for_predicate_name(name: "program_name")
  end

  with_options datastream: :descMetadata do |ds|
    ds.attribute :affiliation,datastream: :descMetadata, hint: "Creator's Affiliation to the Institution.", multiple: false
    ds.attribute :organization,
              datastream: :descMetadata, multiple: true,
              label: "Organization",
              hint: "Organizations which creators belong to."
    ds.attribute :administrative_unit,
              datastream: :descMetadata, multiple: true,
              label: "Departments and Units",
              hint: "Departments and Units that creator belong to."

    ds.attribute :creator,
      multiple: true,
      label: "Author(s)",
      validates: { presence: { message: "Your #{etd_label} must have an Author." } }
    ds.attribute :title,
      label: 'Title',
      hint: "Title of the work as it appears on the title page or equivalent",
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have a title." } }
    ds.attribute :alternate_title,
      label: "Alternate title",
      multiple: false
    ds.attribute :abstract,
      label: "Full text of the abstract",
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have an abstract" } }
    ds.attribute :country,
      label: "Country",
      hint: "The country in which the #{etd_label} was originally published or accepted.",
      multiple: false
    ds.attribute :advisor,
      label: "Advisor",
      hint: "Advisor(s) to the thesis author.",
      multiple: true
    ds.attribute :date_created,
      label: "Date",
      hint: "The date that appears on the title page or equivalent of the #{etd_label}.",
      multiple: false
    ds.attribute :date_uploaded,
      default: lambda { Date.today.to_s("%Y-%m-%d") },
      multiple: false,
      validates: { presence: { message: "You must enter the date uploaded for your #{etd_label}." } }
    ds.attribute :date_modified,
      multiple: false
    ds.attribute :subject,
      label: "Subject",
      hint: "What words or phrases would be helpful for someone searching for your ETD",
      datastream: :descMetadata, multiple: true
    ds.attribute :language,
      hint: "What is the language(s) in which you wrote your #{etd_label}?",
      default: ['English'],
      multiple: true
    ds.attribute :rights,
      default: "All rights reserved",
      multiple: false,
      validates: { presence: { message: "You must select a license for your #{etd_label}." } }
    ds.attribute :permission,
      label: "Use Permission",
      multiple: false
    ds.attribute :note,
      label: "Note",
      multiple: false,
      hint: " Additional information regarding the thesis. Example: acceptance note of the department"
    ds.attribute :publisher,
      hint: "An entity responsible for making the resource available. This is typically the group most directly responsible for digitizing and/or archiving the work.",
      multiple: true
    ds.attribute :code_list,
      datastream: :descMetadata, multiple: false
    ds.attribute :coverage_temporal,
      multiple: true,
      label: "Coverage Temporal",
      hint: " The overall time frame related to the materials if applicable."
    ds.attribute :coverage_spatial,
      multiple: true,
      label: "Coverage Spatial",
      hint: " The general region that the materials are related to when applicable."
    ds.attribute :format,
      multiple: false,
      editable: false
    ds.attribute :urn,
      multiple: false
    ds.attribute :date,
      default: lambda { Date.today.to_s("%Y-%m-%d") },
      multiple: false,
      label: "Defense Date"
    ds.attribute :date_approved,
      multiple: false,
      label: "Approval Date"
    ds.attribute :relation,
      multiple: true,
      label: "Related Resources",
      validates: {
          allow_blank: true,
          format: {
              with: URI::regexp(%w(http https ftp)),
              message: 'must be a valid URL.'
          }
      }
    ds.attribute :alephIdentifier,
      datastream: :descMetadata, multiple: true,
      validates: {
          allow_blank: true,
          aleph_identifier: true
      }
  end

  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

  def to_solr(solr_doc={}, opts={})
    solr_doc[Solrizer.solr_name('degree_name', :stored_searchable)] = degree_name
    solr_doc[Solrizer.solr_name('degree_disciplines', :stored_searchable)] = degree_disciplines
    solr_doc[Solrizer.solr_name('contributors', :stored_searchable)] = contributors_list
    solr_doc[Solrizer.solr_name('degree_department_acronyms', :stored_searchable)] = department_acronyms
    if(cdate = Array.wrap(self.date_created).compact).blank?
      solr_doc[Solrizer.solr_name('desc_metadata__date_created', :stored_searchable)] = cdate.first
    end
    super(solr_doc, opts)
  end

  def contributors_list
    @contributors_list ||= []
    return @contributors_list unless @contributors_list.blank?
    self.contributor.each do |con|
      @contributors_list << con.contributor.first
    end
    @contributors_list
  end

  def degree_name
    self.degree.first.name
  end

  def degree_disciplines
    self.degree.map {|m| m.discipline }.flatten.compact
  end

  def department_acronyms
    # degree_disciplines.collect{|disc| department_acronym_mapper[disc] }.compact
    degree_disciplines.collect do |disc|
      ControlledVocabularyService.labels_for_predicate_name(name: 'program_name')
    end.compact
  end
end
