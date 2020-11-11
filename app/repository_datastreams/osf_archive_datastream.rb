require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"
class OsfArchiveDatastream < ActiveFedora::NtriplesRDFDatastream

  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable
  end

  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.type :string
    index.as :stored_sortable
  end

  property :osf_project_identifier, predicate: ::RDF::ND['osfProjectIdentifier'] do |index|
    index.type :string
    index.as :stored_sortable
  end

  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.as :stored_searchable, :facetable
  end

  property :type, predicate: ::RDF::Vocab::DC.type

  property :language, predicate: ::RDF::Vocab::DC.language

  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'] do |index|
    index.as :stored_searchable, :facetable
  end

  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'] do |index|
    index.as :stored_searchable, :facetable
  end

  property :description, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end

  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_sortable
  end

  property :date_archived, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_sortable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights

  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'] do |index|
    index.as :stored_searchable
  end

  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end

  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions']
end
