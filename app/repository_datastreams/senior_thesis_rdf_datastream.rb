require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"
class SeniorThesisRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable, :displayable
  end
  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :displayable
  end
  property :advisor, predicate: ::RDF::QualifiedDC['contributor#advisor'] do |index|
    index.as :stored_searchable, :displayable
  end
  property :created, predicate: ::RDF::Vocab::DC.created
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :displayable
  end
  property :description, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.type :text
    index.as :stored_searchable, :displayable
  end
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :displayable, :facetable
  end
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'] do |index|
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
  property :issued, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :stored, :displayable
  end
  property :available, predicate: ::RDF::Vocab::DC.available
  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :displayable, :facetable
  end
  property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
  property :source, predicate: ::RDF::Vocab::DC.source
  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :displayable, :facetable
  end
  property :access_rights, predicate: ::RDF::Vocab::DC.accessRights
  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :stored_searchable, :facetable
  end
  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end
  property :content_format, predicate: ::RDF::Vocab::DC.format
  property :extent, predicate: ::RDF::Vocab::DC.extent
  property :requires, predicate: ::RDF::Vocab::DC.requires
  property :identifier, predicate: ::RDF::Vocab::DC.identifier
  property :part, predicate: ::RDF::Vocab::DC.hasPart
  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions']
end
