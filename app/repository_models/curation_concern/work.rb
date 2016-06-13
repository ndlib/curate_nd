module CurationConcern
  module Work
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :library_collections, property: :is_member_of_collection, class_name: "ActiveFedora::Base"
    end

    # Parses a comma-separated string of tokens, returning an array of ids
    def self.ids_from_tokens(tokens)
      tokens.gsub(/\s+/, "").split(',')
    end

    unless included_modules.include?(CurationConcern::Model)
      include CurationConcern::Model
    end
    include Hydra::AccessControls::Permissions

    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      Solrizer.set_field(solr_doc, 'generic_type', 'Work', :facetable)
      Solrizer.set_field(solr_doc, 'admin_unit_hierarchy', get_solr_hierarchy_from_term(self.administrative_unit), :facetable) if self.respond_to?(:administrative_unit)
      return solr_doc
    end

    def get_solr_hierarchy_from_term(terms, opts={})
      hierarchies = []
      terms.each do |term|
        tree_to_solrize = term.split("::")
        hierarchies << tree_to_solrize.each_with_index.map do |_, i|
          tree_to_solrize[0..i].join(':')
        end
      end
      hierarchies.flatten
    end

  end
end
