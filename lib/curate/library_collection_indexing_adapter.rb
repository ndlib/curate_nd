module Curate
  # An implementation of the required methods to integrate with the Curate::Indexer gem.
  # @see Curate::Indexer::Adapters::AbstractAdapter
  module LibraryCollectionIndexingAdapter
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
      solr_document = find_solr_document_by(pid)
      coerce_solr_document_to_index_document(solr_document)
    end

    # @api public
    # @param document [Curate::Indexer::Documents::IndexDocument]
    # @yield Curate::Indexer::Documents::IndexDocument
    def self.each_child_document_of(parent_document, &block)
      # Need to find all documents that have ancestors equal to one or more of the given parent_document's pathnames
      pathname_query = parent_document.pathnames.map do |pathname|
        "_query_:\"{!raw f=#{SOLR_KEY_ANCESTOR_SYMBOLS}}#{pathname.gsub('"', '\"')}\""
      end.join(" OR ")
      results = ActiveFedora::SolrService.query(pathname_query)
      results.each do |solr_document|
        yield(coerce_solr_document_to_index_document(solr_document))
      end
    end

    # @api public
    # @param attributes [Hash]
    # @option pid [String]
    # @return Hash
    def self.write_document_attributes_to_index_layer(attributes = {})
      # As much as I'd love to use the SOLR document, I don't believe this is feasable as not all elements of the
      # document are stored and returned.
      fedora_object = ActiveFedora::Base.find(attributes.fetch(:pid), cast: true)
      solr_document = fedora_object.to_solr

      solr_document[SOLR_KEY_PARENT_PIDS] = attributes.fetch(:parent_pids)
      solr_document[SOLR_KEY_PARENT_PIDS_FACETABLE] = attributes.fetch(:parent_pids)
      solr_document[SOLR_KEY_ANCESTORS] = attributes.fetch(:ancestors)
      solr_document[SOLR_KEY_ANCESTOR_SYMBOLS] = attributes.fetch(:ancestors)
      solr_document[SOLR_KEY_PATHNAMES] = attributes.fetch(:pathnames)

      ActiveFedora::SolrService.add(solr_document)
      ActiveFedora::SolrService.commit
      solr_document
    end

    SOLR_KEY_PARENT_PIDS = ActiveFedora::SolrService.solr_name(:library_collections).freeze
    SOLR_KEY_PARENT_PIDS_FACETABLE = ActiveFedora::SolrService.solr_name(:library_collections, :facetable).freeze
    SOLR_KEY_ANCESTORS = ActiveFedora::SolrService.solr_name(:library_collections_ancestors).freeze
    # Adding the ancestor symbol as a means of looking up relations; This is cribbed from our current version of ActiveFedora's
    # relationship
    SOLR_KEY_ANCESTOR_SYMBOLS = ActiveFedora::SolrService.solr_name(:library_collections_ancestors, :symbol).freeze
    SOLR_KEY_PATHNAMES = ActiveFedora::SolrService.solr_name(:library_collections_pathnames).freeze

    def self.coerce_solr_document_to_index_document(solr_document, pid = solr_document.fetch('id'))
      parent_pids = solr_document.fetch(SOLR_KEY_PARENT_PIDS, [])
      ancestors = solr_document.fetch(SOLR_KEY_ANCESTORS, [])
      pathnames = solr_document.fetch(SOLR_KEY_PATHNAMES, [])
      Curate::Indexer::Documents::IndexDocument.new(pid: pid, parent_pids: parent_pids, pathnames: pathnames, ancestors: ancestors)
    end
    private_class_method :coerce_solr_document_to_index_document

    def self.find_solr_document_by(pid)
      query = ActiveFedora::SolrService.construct_query_for_pids([pid])
      ActiveFedora::SolrService.query(query).first
    end
    private_class_method :find_solr_document_by
  end
end
