module Curate
  # An implementation of the required methods to integrate with the Curate::Indexer gem.
  # @see Curate::Indexer::Adapters::AbstractAdapter
  module IndexingAdapter
    # @api public
    # @param pid [String]
    # @return Curate::Indexer::Document::PreservationDocument
    def self.find_preservation_document_by(pid)
      # Find the active fedora object
      # Map that object to a PreservationDocument
    end

    # @api public
    # @param pid [String]
    # @return Curate::Indexer::Documents::IndexDocument
    def self.find_index_document_by(pid)
      # Find the SOLR object
      # Capture the eTags of the SOLR document for update
      # Map that object to a IndexDocument
    end

    # @api public
    # @yield Curate::Indexer::Document::PreservationDocument
    def self.each_preservation_document
      # Find each of the active fedora objects
      # Within the block, map the fedora object to PreservationDocument
      # Yield the PreservationDocument
    end

    # @api public
    # @param pid [String]
    # @yield Curate::Indexer::Documents::IndexDocument
    def self.each_child_document_of(pid, &block)
      # Find the SOLR documents that are children of the given pid
      # Map each SOLR document to an IndexDocument
      # Yield the IndexDocument
    end

    # @api public
    # @param attributes [Hash]
    # @option pid [String]
    # @return Curate::Indexer::Documents::IndexDocument
    def self.write_document_attributes_to_index_layer(attributes = {})
      # Given the attributes
      # Merge those attributes into the related SOLR document for the object
      # At present, I believe this minds re-find the object and then post an update
    end
  end
end
