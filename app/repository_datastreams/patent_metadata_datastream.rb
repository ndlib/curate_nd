require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"
class PatentMetadataDatastream < ActiveFedora::NtriplesRDFDatastream

  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end

  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :stored_searchable, :facetable
  end

  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :date_issued, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.as :stored_searchable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end

  property :rights_holder, predicate: ::RDF::Vocab::DC.rightsHolder do |index|
    index.as :stored_searchable, :facetable
  end

  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :displayable, :facetable
  end

  property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_searchable, :displayable, :sortable
  end

  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_sortable
  end

  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end

  property :patent_number, predicate: ::RDF::QualifiedDC['identifier#patent'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :other_application, predicate: ::RDF::QualifiedDC['identifier#other_application'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :application_date, predicate: ::RDF::QualifiedDC['date#application'.to_sym] do |index|
    index.as :stored_sortable
  end

  property :prior_publication_date, predicate: ::RDF::QualifiedDC['date#prior_publication'.to_sym] do |index|
    index.as :stored_sortable
  end

  property :prior_publication, predicate: ::RDF::QualifiedDC['identifier#prior_publication'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :number_of_claims, predicate: ::RDF::QualifiedDC['extent#claims'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :us_patent_classification_code, predicate: ::RDF::QualifiedDC['subject#uspc'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :cooperative_patent_classification_code, predicate: ::RDF::QualifiedDC['ubject#cpc'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :international_patent_classification_code, predicate: ::RDF::QualifiedDC['subject#ipc'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :creators_from_local_institution, predicate: ::RDF::QualifiedDC['creator#local'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :patent_office_link, predicate: ::RDF::Vocab::DC.source do |index|
    index.as :stored_searchable
  end

  property :type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable
  end

  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end

  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
end
