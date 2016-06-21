module CurationConcern
  module IsMemberOfLibraryCollection
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :library_collections, property: :is_member_of_collection, class_name: "ActiveFedora::Base"
    end

    # These are the easy library collection relationships that can be solrized without the full anctics of crawling the relationship graph.
    #
    # @see Curate::LibraryCollectionIndexingAdapter.write_document_attributes_to_index_layer
    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      solr_doc[Curate::LibraryCollectionIndexingAdapter::SOLR_KEY_PARENT_PIDS_FACETABLE] = self.library_collection_ids
      solr_doc[Curate::LibraryCollectionIndexingAdapter::SOLR_KEY_PARENT_PIDS] = self.library_collection_ids
      solr_doc
    end
  end
end
