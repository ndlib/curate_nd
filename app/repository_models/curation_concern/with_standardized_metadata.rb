module CurationConcern
  module WithStandardizedMetadata
      # Map from the list of valid metadata methods to the desired new key
      # the CurationConcern is tested with every key below, to see if it responds to that method, so only desired values should be included for mapping
      # (See commented list of all method options at end of this module)

      # if a method on the CurationConcern returns an object (which responds to :nested_attributes_options), this also allows us call a method on that returned object, and return the new value instead.
      ATTRIBUTE_MAP = {
      pid: :identifier,
      human_readable_type: :worktype,
      title: :title,
      creator: :creator,
      author: :creator,
      abstract: :description,
      description: :description,
      date_uploaded: :date_deposited,
      date_archived: :date_deposited,
      date_modified: :date_modified,
      date_created: :date_created,
      date: :date_defended,
      publication_date: :date_published,
      doi: :doi,
      issn: :issn,
      eIssn: :eissn,
      isbn: :isbn,
      is_part_of: :journal_title,
      volume: :volume,
      issue: :issue,
      administrative_unit: :administrative_unit,
      subject: :subject,
      # look in NESTED_ATTR for key contributor if value is a nested object
      # if value is not a nested object, it simply maps to key contributor.
      contributor: :contributor,  # look in NESTED_ATTR for key contributor
      contributor_contributor: :contributor, # call contributor and return as :contributor
      language: :language,
      rights: :rights,
      library_collections: :collection, # look in NESTED_ATTR for key collection
      collection_title: :is_part_of, # call title and return as :is_part_of
      collection_noid: :collection_id # call noid and return as :collection_id
    }

    # a hash storing methods to be called on a returned value that responds to :nested_attributes_options, in order to return a deeper attribute
    # only methods desired in standardized output must be part of the value array
    NESTED_ATTR = {
      contributor: [:contributor], # [:contributor, :role]
      degree: [], # [:discipline, :level, :name]
      collection: [:title, :noid]
    }

    # a mapping of each worktype's model into a standard set of attributes
    def standardize
      std = {}
      ATTRIBUTE_MAP.each_pair do |attribute, map_to|
        if self.respond_to?(attribute) && !self.send(attribute).blank?
          attribute_value = self.send(attribute)
          if (attribute_value.is_a?(Array) && attribute_value.first.respond_to?(:nested_attributes_options)) || attribute_value.respond_to?(:nested_attributes_options)
            # make sure we have methods defined to use on the attribute
            next if NESTED_ATTR[map_to].blank?
            # for each nested attribute method,
            # ~> build the new attribute name
            # ~> check if we have a mapping for the new attribute
            NESTED_ATTR[map_to].each do |nested_method|
              new_attribute = (map_to.to_s + '_' + nested_method.to_s).to_sym
              if !ATTRIBUTE_MAP[new_attribute].blank?
                # if so, map the attribute's values
                Array.wrap(attribute_value).each do |element|
                  merge_attribute(
                    attribute_hash: std,
                    orig_attribute: new_attribute,
                    new_attribute: ATTRIBUTE_MAP[new_attribute],
                    value: element.send(nested_method)
                  )
                end
              end
            end
          else
            merge_attribute(
              attribute_hash: std,
              orig_attribute: attribute,
              new_attribute: map_to,
              value: attribute_value
            )
          end
        end
      end
      std
    end

    def merge_attribute(attribute_hash:, orig_attribute:, new_attribute:, value:)
      if attribute_hash.keys.include?(orig_attribute)
        attribute_hash[new_attribute] = (Array.wrap(attribute_hash[orig_attribute]) + Array.wrap(value))
      else
        attribute_hash[new_attribute] = value
      end
    end
    # Curate metadata attributes
    # abstract
    # access_rights
    # administrative_unit
    # advisor
    # affiliation
    # alephIdentifier
    # alternate_email
    # alternate_phone_number
    # alternate_title
    # application_date
    # artist
    # assign_doi
    # author
    # available
    # based_near
    # bibliographic_citation
    # blog
    # campus_phone_number
    # coauthor
    # code_list
    # collection_name
    # composer
    # conductor
    # content_format
    # contributing_artist
    # contributing_editor
    # contributing_illustrator
    # contributing_photographer
    # contributor
    # contributor_institution
    # contributor.*
    # contributor.name
    # contributor.role
    # cooperative_patent_classification_code
    # copyright_date
    # country
    # coverage_spatial
    # coverage_temporal
    # created
    # creator
    # creators_from_local_institution
    # curator
    # data_processing
    # date
    # date_approved
    # date_archived
    # date_created
    # date_digitized
    # date_issued
    # date_modified
    # date_of_birth
    # date_uploaded
    # degree.*
    # degree_discipline
    # degree.discipline
    # degree.level
    # degree.name
    # description
    # digitizing_equipment
    # director
    # doi
    # duration
    # edition
    # editor
    # eIssn
    # email
    # event_speaker
    # extent
    # file_structure
    # format
    # gender
    # genre
    # identifier
    # illustrator
    # international_patent_classification_code
    # interviewee
    # interviewer
    # is_part_of
    # is_version_of
    # isbn
    # issn
    # issue
    # issued
    # issued_by
    # language
    # lc_subject
    # local_identifier
    # methodology
    # name
    # note
    # number_of_claims
    # num_pages
    # organization
    # original_media_source
    # osf_project_identifier
    # other_application
    # page_end
    # page_start
    # part
    # part_of
    # patent_number
    # patent_office_link
    # performer
    # permission
    # personal_webpage
    # photographer
    # prior_publication
    # prior_publication_date
    # producer
    # production_company
    # promulgated_by
    # promulgated_date
    # publication_date
    # publisher
    # recommended_citation
    # related_url
    # relation
    # repository_name
    # requires
    # resource_type
    # rights
    # rights_holder
    # screenwriter
    # size
    # source
    # spatial
    # spatial_coverage
    # speaker
    # subject
    # table_of_contents
    # tag
    # temporal
    # temporal_coverage
    # title
    # type
    # urn
    # us_patent_classification_code
    # variable_list
    # volume
    # vra_cultural_context
    # vra_depicts
    # vra_depth
    # vra_derived_from
    # vra_designer
    # vra_diameter
    # vra_facsimile_of
    # vra_has_technique
    # vra_height
    # vra_image_of
    # vra_length
    # vra_manufacturer
    # vra_mate_of
    # vra_material
    # vra_partner_in_set_with
    # vra_place_of_creation
    # vra_place_of_discovery
    # vra_place_of_exhibition
    # vra_place_of_installation
    # vra_place_of_publication
    # vra_place_of_repository
    # vra_place_of_site
    # vra_plan_for
    # vra_preparatory_for
    # vra_printer
    # vra_printing_plate_for
    # vra_prototype_for
    # vra_relief_for
    # vra_replica_of
    # vra_study_for
    # vra_was_alteration
    # vra_was_commission
    # vra_was_designed
    # vra_was_destroyed
    # vra_was_discovered
    # vra_was_performed
    # vra_was_presented
    # vra_was_produced
    # vra_was_restored
    # vra_weight
    # vra_width
    # work_author
  end
end
