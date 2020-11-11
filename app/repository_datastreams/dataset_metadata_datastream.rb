require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"

class DatasetMetadataDatastream < ActiveFedora::NtriplesRDFDatastream
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end
  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end
  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :facetable
  end
  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :organization, predicate: ::RDF::QualifiedDC['creator#organization'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end
  property :publication_date, predicate: ::RDF::Vocab::DC.issued do |index|
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
  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.type :text
    index.as :stored_searchable
  end
  property :methodology, predicate: ::RDF::QualifiedDC['description#methodology'.to_sym]
  property :data_processing, predicate: ::RDF::QualifiedDC['description#data_processing'.to_sym]
  property :file_structure, predicate: ::RDF::QualifiedDC['description#file_structure'.to_sym]
  property :variable_list, predicate: ::RDF::QualifiedDC['description#variable_list'.to_sym]
  property :code_list, predicate: ::RDF::QualifiedDC['description#code_list'.to_sym]
  property :spatial_coverage, predicate: ::RDF::Vocab::DC.spatial
  property :temporal_coverage, predicate: ::RDF::Vocab::DC.temporal
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end
  property :identifier, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym]
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end
  property :contributor_institution, predicate: ::RDF::QualifiedDC['contributor#institution'.to_sym]
  property :source, predicate: ::RDF::Vocab::DC.source
  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :stored_searchable, :facetable
  end
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  property :recommended_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
  property :repository_name, predicate: ::RDF::QualifiedDC['contributor#repository'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :collection_name, predicate: ::RDF::QualifiedDC['relation#ispartof'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :size, predicate: ::RDF::QualifiedDC['format#extent'.to_sym]
  property :requires, predicate: ::RDF::Vocab::DC.requires
  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end
end
