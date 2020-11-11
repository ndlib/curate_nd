require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"

class FindingAidRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable, :displayable
  end

  property :created, predicate: ::RDF::Vocab::DC.created

  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :displayable
  end

  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :displayable
  end

  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_searchable, :displayable, :sortable
  end

  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.type :date
    index.as :stored_searchable, :displayable
  end

  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_searchable, :displayable, :sortable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :displayable, :facetable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier

  property :part, predicate: ::RDF::Vocab::DC.hasPart

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :stored_searchable, :displayable
  end

  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end

  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end

  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
end
