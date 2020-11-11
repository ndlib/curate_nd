require "rdf/vocab"

class GroupMetadataDatastream < ActiveFedora::NtriplesRDFDatastream
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_sortable
  end

  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_sortable
  end

end
