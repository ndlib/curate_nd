class GenericFile < ActiveFedora::Base
  include ActiveModel::Validations
  include Sufia::ModelMethods
  include Hydra::ModelMethods
  include Hydra::AccessControls::Permissions # must be prior to embargoable
  include CurationConcern::Embargoable # overrides visibility, so must come after Permissions
  include Sufia::GenericFile::Characterization
  include Curate::ActiveModelAdaptor
  include Sufia::GenericFile::Versions
  include Sufia::GenericFile::Audit
  include Sufia::GenericFile::MimeTypes
  include Sufia::GenericFile::Thumbnail
  include Sufia::GenericFile::Derivatives
  include CurationConcern::WithJsonMapper
  include CurationConcern::RemotelyIdentifiedByDoi::Attributes
  include CurationConcern::WithStandardizedMetadata

  belongs_to :batch, property: :is_part_of, class_name: 'ActiveFedora::Base'
  before_destroy :check_and_clear_parent_representative

  has_metadata "descMetadata", type: Sufia::GenericFileRdfDatastream
  has_metadata 'properties', type: Curate::PropertiesDatastream
  has_file_datastream "content", type: FileContentDatastream
  has_file_datastream "thumbnail"

  has_attributes :owner, :depositor, datastream: :properties, multiple: false
  has_attributes :date_uploaded, :date_modified, datastream: :descMetadata, multiple: false
  has_attributes :creator, :title, datastream: :descMetadata, multiple: true
  has_attributes :description, datastream: :descMetadata, multiple: false
  has_attributes :alephIdentifier, datastream: :descMetadata, multiple: true,
    validates: {
        allow_blank: true,
        aleph_identifier: true
    }

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "An arbitrary single file."

  attribute :title,
    datastream: :descMetadata, multiple: false,
    label: "Title of your File"
  attribute :permission,
    label: "Use Permission",
    datastream: :descMetadata, multiple: false

  attr_accessor :file, :version

  alias parent batch

  def filename
    return 'File Upload Error' if with_empty_content?
    content.label || "no filename given"
  end

  def with_empty_content?
    content.blank?
  end

  def to_s
    filename
  end

  def versions
    return [] unless persisted?
    @versions ||= content.versions.collect {|version| Curate::ContentVersion.new(content, version)}
  end

  def latest_version
    versions.first || Curate::ContentVersion::Null.new(content)
  end

  def current_version_id
    latest_version.version_id
  end

  def human_readable_type
    self.class.to_s.demodulize.titleize
  end

  def representative
    pid
  end

  def copy_permissions_from(obj)
    self.datastreams['rightsMetadata'].ng_xml = obj.datastreams['rightsMetadata'].ng_xml
  end

  def update_parent_representative_if_empty(obj)
    return unless obj.representative.blank?
    obj.representative = self.pid
    obj.save
  end

  private
  def check_and_clear_parent_representative
    if batch.representative == self.pid
      batch.representative = batch.generic_file_ids.select{|i| i if i != self.pid}.first
      batch.save!
    end
  end
end
