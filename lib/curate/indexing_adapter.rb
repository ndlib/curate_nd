module Curate
  # An implementation of the required methods to integrate with the Curate::Indexer gem.
  # @see Curate::Indexer::Adapters::AbstractAdapter
  module IndexingAdapter
    # @api public
    # @param pid [String]
    # @return Curate::Indexer::Documents::PreservationDocument
    def self.find_preservation_document_by(pid)
      # Not everything is guaranteed to have library_collection_ids
      # If it doesn't have it, what do we do?
      fedora_object = ActiveFedora::Base.find(pid, cast: true)
      if fedora_object.respond_to?(:library_collection_ids)
        parent_pids = fedora_object.library_collection_ids
      else
        parent_pids = []
      end
      Curate::Indexer::Documents::PreservationDocument.new(pid: pid, parent_pids: parent_pids)
    end

    # @api public
    # @yield Curate::Indexer::Documents::PreservationDocument
    def self.each_preservation_document
      query = "pid~#{Sufia.config.id_namespace}:*"
      ActiveFedora::Base.send(:connections).each do |conn|
        conn.search(query) do |object|
          next if object.pid.start_with?(ReindexWorker::FEDORA_SYSTEM_PIDS)
          # Because I have a Rubydora object, I need to find it via ActiveFedora, thus the reuse.
          yield(find_preservation_document_by(object.pid))
        end
      end
    end

    # @api public
    # @param pid [String]
    # @return Curate::Indexer::Documents::IndexDocument
    def self.find_index_document_by(pid)
      query = ActiveFedora::SolrService.construct_query_for_pids([pid])
      solr_document = ActiveFedora::SolrService.query(query).first
      parent_pids = solr_document.fetch(Solrizer.solr_name(:library_collections), [])
      ancestors = solr_document.fetch(Solrizer.solr_name(:ancestors), [])
      pathnames = solr_document.fetch(Solrizer.solr_name(:pathnames), [])
      Curate::Indexer::Documents::IndexDocument.new(pid: pid, parent_pids: parent_pids, pathnames: pathnames, ancestors: ancestors)
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
