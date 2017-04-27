# A modified version of the "traditional" collection model
#
# It is assumed that LibraryCollections are visible to the public.
# There may be members of the collection that are not visible.
class LibraryCollection < ActiveFedora::Base
  include Hydra::ModelMethods # for access to apply_depositor_metadata
  include Sufia::Noid
  include Hydra::AccessControls::Permissions
  include Hydra::AccessControls::WithAccessRight
  include Hydra::Derivatives
  include CurationConcern::HumanReadableType
  include CurationConcern::WithJsonMapper
  has_metadata "descMetadata", type: LibraryCollectionRdfDatastream
  has_metadata "properties", type: Curate::PropertiesDatastream

  has_many :library_collection_members, property: :is_member_of_collection, class_name: "ActiveFedora::Base"

  include CurationConcern::IsMemberOfLibraryCollection

  # include CurationConcern::WithRecordViewers
  # has_and_belongs_to_many :record_viewers, class_name: "::Person", property: :has_viewer, inverse_of: :is_viewer_of
  # has_and_belongs_to_many :record_viewer_groups, class_name: "::Hydramata::Group", property: :has_viewer_group, inverse_of: :is_viewer_group_of
  # accepts_nested_attributes_for :record_viewers, allow_destroy: true, reject_if: :all_blank
  # accepts_nested_attributes_for :record_viewer_groups, allow_destroy: true, reject_if: :all_blank

  has_attributes :depositor, :representative, datastream: :properties, multiple: false
  has_attributes :title, :date_uploaded, :date_modified, :description,
                 datastream: :descMetadata, multiple: false
  has_attributes :creator, :contributor, :based_near, :part_of, :publisher,
                 :date_created, :subject, :resource_type, :rights,
                 :identifier, :language, :relation, :related_url,
                 :administrative_unit, :source, :curator, :date, :temporal, :spatial,
                 datastream: :descMetadata, multiple: true

  def can_be_member_of_collection?(collection)
    collection == self ? false : true
  end

  def self.human_readable_type
    'Collection'
  end

  # Returns a string identifying the path associated with the object. ActionPack uses this to find a suitable partial to represent the object.
  def to_partial_path
    "curation_concern/#{super}"
  end

  def to_s
    title
  end

  def to_solr(solr_doc={}, opts={})
    super(solr_doc, opts)
    Solrizer.set_field(solr_doc, 'generic_type', human_readable_type, :facetable)
    solr_doc[Solrizer.solr_name('representative', :stored_searchable)] = self.representative
    solr_doc
  end

  def check_and_clear_representative
    begin
      GenericFile.load_instance_from_solr(self.representative) if self.representative.present?
    rescue ActiveFedora::ObjectNotFoundError
      representative_pid = self.representative
      self.representative = self.generic_file_ids.select{|i| i if i != representative_pid}.first
      self.save!
    end
  end

  private :date_uploaded=, :date_modified=

  private

  before_validation :set_visibility_to_public
  def set_visibility_to_public
    self.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
  end

  before_create :set_date_uploaded
  before_save :set_date_modified

  def set_date_uploaded
    self.date_uploaded = Date.today
  end

  def set_date_modified
    self.date_modified = Date.today
  end
end
