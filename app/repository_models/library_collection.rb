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

  has_metadata "descMetadata", type: LibraryCollectionRdfDatastream
  has_metadata "properties", type: Hydra::Datastream::Properties

  has_many :library_collection_members, property: :is_member_of_collection, class_name: "ActiveFedora::Base"

  include CurationConcern::IsMemberOfLibraryCollection

  # include CurationConcern::WithRecordViewers
  # has_and_belongs_to_many :record_viewers, class_name: "::Person", property: :has_viewer, inverse_of: :is_viewer_of
  # has_and_belongs_to_many :record_viewer_groups, class_name: "::Hydramata::Group", property: :has_viewer_group, inverse_of: :is_viewer_group_of
  # accepts_nested_attributes_for :record_viewers, allow_destroy: true, reject_if: :all_blank
  # accepts_nested_attributes_for :record_viewer_groups, allow_destroy: true, reject_if: :all_blank

  has_attributes :depositor, datastream: :properties, multiple: false
  has_attributes :title, :date_uploaded, :date_modified, :description,
                 datastream: :descMetadata, multiple: false
  has_attributes :creator, :contributor, :based_near, :part_of, :publisher,
                 :date_created, :subject, :resource_type, :rights,
                 :identifier, :language, :tag, :related_url,
                 :administrative_unit, :source, :curator, :date,
                 datastream: :descMetadata, multiple: true

  has_file_datastream name: "content"
  has_file_datastream name: "medium"
  has_file_datastream name: "thumbnail"

  def can_be_member_of_collection?(collection)
    collection == self ? false : true
  end

  def representative_image_url
    return nil unless thumbnail.content.present?
    "/downloads/#{self.representative}/thumbnail"
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
    solr_doc[Solrizer.solr_name('representative_image_url', :stored_searchable)] = self.representative_image_url
    solr_doc
  end

  def representative
    to_param
  end

  # Are these hold outs of the profile section?
  attr_accessor :mime_type
  attr_accessor :file

  private :date_uploaded=, :date_modified=

  private

  makes_derivatives :generate_derivatives

  before_save :add_file_image

  def add_file_image
    return unless file
    self.content.content = file
    self.mime_type = file.content_type
    generate_derivatives
  end

  def generate_derivatives
    case mime_type
    when 'image/png', 'image/jpeg', 'image/tiff'
      transform_datastream(
        :content,
        medium: { size: "300x300>", datastream: 'medium' },
        thumb: { size: "100x100>", datastream: 'thumbnail' }
      )
    end
  end

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
