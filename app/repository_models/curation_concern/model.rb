module CurationConcern
  module Model
    extend ActiveSupport::Autoload
    extend ActiveSupport::Concern


    included do
      include Sufia::ModelMethods
      include Hydra::ModelMethods
      include Curate::ActiveModelAdaptor

      #after_solrize << :index_collection_pids
      has_many :collections, property: :has_collection_member, :class_name => "ActiveFedora::Base"

      include Solrizer::Common
      include CurationConcern::HumanReadableType
      include CurationConcern::WithStandardizedMetadata

      include CurationConcern::WithCollaborators
      has_and_belongs_to_many :record_editors, class_name: "::Person", property: :has_editor
      accepts_nested_attributes_for :record_editors, allow_destroy: true, reject_if: :all_blank
      has_and_belongs_to_many :record_editor_groups, class_name: "::Hydramata::Group", property: :has_editor_group
      accepts_nested_attributes_for :record_editor_groups, allow_destroy: true, reject_if: :all_blank

      has_and_belongs_to_many :record_viewers, class_name: "::Person", property: :has_viewer
      accepts_nested_attributes_for :record_viewers, allow_destroy: true, reject_if: :all_blank
      has_and_belongs_to_many :record_viewer_groups, class_name: "::Hydramata::Group", property: :has_viewer_group
      accepts_nested_attributes_for :record_viewer_groups, allow_destroy: true, reject_if: :all_blank

      has_metadata 'properties', type: Curate::PropertiesDatastream
      has_attributes :relative_path, :depositor, :owner, :representative, :license, :type_of_license, datastream: :properties, multiple: false
      class_attribute :human_readable_short_description
    end

    def as_json(options)
      { pid: pid, title: title, model: self.class.to_s, curation_concern_type: human_readable_type }
    end

    def as_rdf_object
      RDF::URI.new(internal_uri)
    end

    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      index_collection_pids(solr_doc)
      solr_doc[Solrizer.solr_name('noid', Sufia::GenericFile.noid_indexer)] = noid
      solr_doc[Solrizer.solr_name('representative', :stored_searchable)] = self.representative
      add_derived_date_created(solr_doc)
      return solr_doc
    end

    def to_s
      title
    end

    # Returns a string identifying the path associated with the object. ActionPack uses this to find a suitable partial to represent the object.
    def to_partial_path
      "curation_concern/#{super}"
    end

    def can_be_member_of_collection?(collection)
      collection == self ? false : true
    end

    def index_collection_pids(solr_doc={})
      solr_doc[Solrizer.solr_name(:collection, :facetable)] = self.collection_ids
      solr_doc[Solrizer.solr_name(:collection)] = self.collection_ids
      solr_doc
    end

protected

    # A single searchable/sortable date field that is derived from other (text) fields
    def add_derived_date_created(solr_doc)
      # The derived date is assigned based on a priority sequence of:
      # Publication Date -> Date Issued -> Date Created
      # This seems to be a global pattern for these fields across all models,
      # so I'm putting this here. If this changes, then it may make sense to move
      # this logic into the individual model's to_solr methods.
      # See ticket DLTP-1258
      derived_date = case true
      when self.respond_to?(:publication_date)
        parse_date(publication_date)
      when self.respond_to?(:date_issued)
        parse_date(date_issued)
      when self.respond_to?(:date)
        parse_date(date)
      when self.respond_to?(:date_created)
        parse_date(date_created)
      end
      self.class.create_and_insert_terms('date_created_derived', derived_date, [:stored_sortable], solr_doc)
    end

    def parse_date(source_date)
      Curate::DateFormatter.parse(source_date.to_s) unless source_date.blank?
    end

    def index_collection_pids(solr_doc)
      solr_doc[Solrizer.solr_name(:collection, :facetable)] ||= []
      solr_doc[Solrizer.solr_name(:collection)] ||= []
      self.collection_ids.each do |collection_id|
        collection_obj = ActiveFedora::Base.load_instance_from_solr(collection_id)
        if collection_obj.is_a?(Collection)
          solr_doc[Solrizer.solr_name(:collection, :facetable)] << collection_id
          solr_doc[Solrizer.solr_name(:collection)] << collection_id
        end
      end
      solr_doc
    end
  end
end
