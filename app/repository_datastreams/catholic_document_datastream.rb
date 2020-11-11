require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
class CatholicDocumentDatastream < ActiveFedora::NtriplesRDFDatastream
  # Title
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end

  # Alternate Title
  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end

  # Description
  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end

  # Author
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end

  # Issued By
  property :issued_by, predicate: ::RDF::Vocab::MARCRelators.isb do |index|
    index.as :stored_searchable
  end

  # Promulgated By
  property :promulgated_by, predicate: ::RDF::ND.promulgatingBody do |index|
    index.as :stored_searchable
  end

  # Date Published
  property :date_issued, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :stored_searchable
  end

  # Date Issued
  property :date, predicate: ::RDF::Vocab::DC.date

  # Date Promulgated
  property :promulgated_date, predicate: ::RDF::Vocab::DC.valid

  #Subjects
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  # Number of pages
  property :extent, predicate: ::RDF::Vocab::DC.extent

  # Spacial Coverage
  property :spatial_coverage, predicate: ::RDF::Vocab::DC.spatial

  # Temporal Coverage
  property :temporal_coverage, predicate: ::RDF::Vocab::DC.temporal

  # Language
  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :searchable, :facetable
  end

  # Document Type
  property :type, predicate: ::RDF::Vocab::DC.type do |index|
    index.type :text
    index.as :stored_searchable
  end

  # Repository
  property :repository_name, predicate: ::RDF::QualifiedDC['creator#repository'.to_sym]

  # Publisher
  property :publisher, predicate: ::RDF::Vocab::DC.publisher

  # Source
  property :source, predicate: ::RDF::Vocab::DC.source

  # Rights Holder
  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder

  # Copyright Date
  property :copyright_date, predicate: ::RDF::Vocab::DC.dateCopyrighted

  # Requires
  property :requires, predicate: ::RDF::Vocab::DC.requires

  # Standard metadata:
  # Departments & Units
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end

  property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_sortable
  end

  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_sortable
  end

  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end

  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
end
