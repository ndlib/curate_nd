class Image < ActiveFedora::Base
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

  has_metadata "descMetadata", type: ImageMetadata

  image_label = 'image'

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Any image file: art, photograph, poster, etc."

  # we have not specified a preferred format
  def preferred_file_format
    ''
  end

  with_options datastream: :descMetadata do |ds|
    ds.attribute :title,
      label: 'Title',
      hint: "Title of the item.",
      multiple: false,
      validates: { presence: { message: "Your #{image_label} must have a title." } }

    ds.attribute :creator,
      label: "Creator",
      hint: " Primary creator/s of the item.",
      multiple: true,
      validates: { multi_value_presence: { message: "Your #{image_label} must have a creator." } }

    ds.attribute :affiliation,datastream: :descMetadata, hint: "Creator's Affiliation to the Institution.", multiple: false

    ds.attribute :organization,
              datastream: :descMetadata, multiple: true,
              label: "Organization",
              hint: "Organizations which creators belong to."

    ds.attribute :administrative_unit,
              datastream: :descMetadata, multiple: true,
              label: "Departments and Units",
              hint: "Departments and Units that creator belong to."

    ds.attribute :date_created,
      default: lambda { Date.today.to_s("%Y-%m-%d") },
      label: "Date",
      hint: "The date or date range the item was created.",
      multiple: false,
      validates: { presence: { message: "Your #{image_label} must have a date." } }

    ds.attribute :description,
      label: "Description",
      multiple: false

    ds.attribute :alternate_title,
      label: "Alternate Title",
      multiple: true

    ds.attribute :contributor,
      label: "Contributor",
      multiple: true

    ds.attribute :contributor_institution,
      label: "Contributor Institution",
      multiple: true

    ds.attribute :source,
      label: 'Source',
      multiple: true

    ds.attribute :publisher,
      label: 'publisher',
      multiple: true

    ds.attribute :date_digitized,
      label: 'Date Digitized',
      multiple: true

    ds.attribute :recommended_citation,
      label: 'Recommended Citation',
      multiple: true

    ds.attribute :temporal_coverage,
      label: 'Temporal Coverage',
      multiple: true

    ds.attribute :spatial_coverage,
      label: 'Spatial Coverage',
      multiple: true

    ds.attribute :digitizing_equipment,
      label: 'Digitizing Equipment',
      multiple: true

    ds.attribute :language,
      label: 'Language',
      multiple: true

    ds.attribute :size,
      label: 'Size',
      multiple: true

    ds.attribute :requires,
      label: 'Requires',
      multiple: true

    ds.attribute :subject,
      label: 'Subject Keywords',
      multiple: true

    ds.attribute :date_uploaded,
      multiple: false

    ds.attribute :date_modified,
      multiple: false

    ds.attribute :rights,
      default: "All rights reserved",
      multiple: false

    ds.attribute :permission,
      label: "Use Permission",
      multiple: false

    ds.attribute :basic_identifier,
      multiple: false,
      editable: false

    ds.attribute :relation,
       multiple: true,
       label: "Related Resource(s)",
       validates: {
           allow_blank: true,
           format: {
               with: URI::regexp(%w(http https ftp)),
               message: 'must be a valid URL.'
           }
       }
    attribute :alephIdentifier,         datastream: :descMetadata, multiple: true,
      validates: {
          allow_blank: true,
          aleph_identifier: true
      }

      ds.attribute :vra_designer,
      	label: 'Designer',
      	multiple: true

      ds.attribute :vra_manufacturer,
      	label: 'Manufacturer',
      	multiple: true

      ds.attribute :vra_printer,
      	label: 'Printer',
      	multiple: true

      ds.attribute :vra_has_technique,
      	label: 'Technique',
      	multiple: true

      ds.attribute :vra_material,
      	label: 'Material',
      	multiple: true

      ds.attribute :vra_cultural_context,
      	label: 'Cultural Context',
      	multiple: true

      ds.attribute :is_part_of,
      	label: 'Part Of',
      	multiple: true

      ds.attribute :is_version_of,
      	label: 'Version Of',
      	multiple: true

      ds.attribute :vra_depth,
      	label: 'Depth',
      	multiple: true

      ds.attribute :vra_diameter,
      	label: 'Diameter',
      	multiple: true

      ds.attribute :vra_height,
      	label: 'Height',
      	multiple: true

      ds.attribute :vra_length,
      	label: 'Length',
      	multiple: true

      ds.attribute :vra_width,
      	label: 'Width',
      	multiple: true

      ds.attribute :vra_weight,
      	label: 'Weight',
      	multiple: true

      ds.attribute :vra_was_performed,
      	label: 'Performance Date',
      	multiple: true

      ds.attribute :vra_was_presented,
      	label: 'Presentation Date',
      	multiple: true

      ds.attribute :vra_was_produced,
      	label: 'Production Date',
      	multiple: false

      ds.attribute :date_issued,
      	label: 'Publication Date',
      	multiple: false

      ds.attribute :vra_plan_for,
      	label: 'Plan For',
      	multiple: true

      ds.attribute :vra_preparatory_for,
      	label: 'Preparatory Work For',
      	multiple: true

      ds.attribute :vra_printing_plate_for,
      	label: 'Printing Plate For',
      	multiple: true

      ds.attribute :vra_prototype_for,
      	label: 'Prototype For',
      	multiple: true

      ds.attribute :vra_relief_for,
      	label: 'Relief For',
      	multiple: true

      ds.attribute :vra_replica_of,
      	label: 'Replica Of',
      	multiple: true

      ds.attribute :vra_study_for,
      	label: 'Study For',
      	multiple: true

      ds.attribute :vra_depicts,
      	label: 'Depicts',
      	multiple: true

      ds.attribute :vra_image_of,
      	label: 'Image Of',
      	multiple: true

      ds.attribute :vra_derived_from,
      	label: 'Derives From',
      	multiple: true

      ds.attribute :vra_facsimile_of,
      	label: 'Facsimile Of',
      	multiple: true

      ds.attribute :vra_mate_of,
      	label: 'Mate Of',
      	multiple: true

      ds.attribute :vra_partner_in_set_with,
      	label: 'In Set With',
      	multiple: true

      ds.attribute :vra_was_alteration,
      	label: 'Alteration Date',
      	multiple: true

      ds.attribute :vra_was_commission,
      	label: 'Commission Date',
      	multiple: false

      ds.attribute :vra_was_designed,
      	label: 'Design Date',
      	multiple: false

      ds.attribute :vra_was_destroyed,
      	label: 'Destruction Date',
      	multiple: false

      ds.attribute :vra_was_discovered,
      	label: 'Discovery Date',
      	multiple: false

      ds.attribute :vra_was_restored,
      	label: 'Restoration Date',
      	multiple: true

      ds.attribute :vra_place_of_creation,
      	label: 'Place of Creation',
      	multiple: true

      ds.attribute :vra_place_of_discovery,
      	label: 'Place of Discovery',
      	multiple: true

      ds.attribute :vra_place_of_exhibition,
      	label: 'Place of Exhibition',
      	multiple: true

      ds.attribute :vra_place_of_installation,
      	label: 'Place of Installation',
      	multiple: true

      ds.attribute :vra_place_of_publication,
      	label: 'Place of Publication',
      	multiple: true

      ds.attribute :vra_place_of_repository,
      	label: 'Place of Repository',
      	multiple: true

      ds.attribute :vra_place_of_site,
      	label: 'Place of Site',
      	multiple: true


  end

  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
