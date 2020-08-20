require 'active_fedora'
require File.expand_path('../../../../lib/rdf/vocab/qualified_dc', __FILE__)
require "rdf/vocab"

module Hydra
  class CollectionRdfDatastream < ActiveFedora::NtriplesRDFDatastream
    property :part_of, predicate: ::RDF::Vocab::DC.isPartOf
    property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
      index.as :stored_searchable, :facetable
    end
    property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
    property :title, predicate: ::RDF::Vocab::DC.title do |index|
      index.as :stored_searchable
    end
    property :description, predicate: ::RDF::Vocab::DC.description do |index|
      index.type :text
      index.as :stored_searchable
    end
    property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
      index.as :stored_searchable, :facetable
    end
    property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'] do |index|
      index.as :stored_searchable, :facetable
    end
    property :curator, predicate: ::RDF::QualifiedDC['contributor#curator'] do |index|
      index.as :stored_searchable, :facetable
    end
    property :date, predicate: ::RDF::Vocab::DC.date do |index|
      index.as :stored_searchable
    end
    property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
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
    property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
      index.as :stored_searchable, :facetable
    end
    property :language, predicate: ::RDF::Vocab::DC.language do |index|
      index.as :stored_searchable, :facetable
    end
    property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
      index.as :stored_searchable
    end
    property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
      index.as :stored_searchable, :facetable
    end
    property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
      index.as :stored_searchable
    end
    property :based_near, predicate: ::RDF::FOAF.based_near do |index|
      index.as :stored_searchable, :facetable
    end
    property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
      index.as :stored_searchable, :facetable
    end
    property :related_url, predicate: ::RDF::Vocab::RDFS.seeAlso
    property :source, predicate: ::RDF::Vocab::DC.source
  end
end
