module CurationConcern
  module Work
    extend ActiveSupport::Concern

    # Parses a comma-separated string of tokens, returning an array of ids
    def self.ids_from_tokens(tokens)
      tokens.gsub(/\s+/, "").split(',')
    end

    include CurationConcern::Model
    include Hydra::AccessControls::Permissions

    included do
      include CurationConcern::IsMemberOfLibraryCollection
    end

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
