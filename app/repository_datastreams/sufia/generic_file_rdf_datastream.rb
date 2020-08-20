require File.expand_path('../../../../lib/rdf/vocab/nd', __FILE__)
module Sufia
  class GenericFileRdfDatastream < ActiveFedora::NtriplesRDFDatastream
    property :part_of, predicate: ::RDF::Vocab::DC.isPartOf
    property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
      index.as :stored_searchable, :facetable
    end
    property :title, predicate: ::RDF::Vocab::DC.title do |index|
      index.as :stored_searchable
    end
    property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
      index.as :stored_searchable, :facetable
    end
    property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
      index.as :stored_searchable, :facetable
    end
    property :description, predicate: ::RDF::Vocab::DC.description do |index|
      index.type :text
      index.as :stored_searchable
    end
    property :tag, predicate: ::RDF::Vocab::DC.relation do |index|
      index.as :stored_searchable, :facetable
    end
    property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
      index.as :stored_searchable
    end
    property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
      index.as :stored_searchable, :facetable
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
    property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
      index.as :stored_searchable
    end
    property :based_near, predicate: ::RDF::FOAF.based_near do |index|
      index.as :stored_searchable, :facetable
    end
    property :related_url, predicate: ::RDF::Vocab::RDFS.seeAlso
    property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
      index.as :stored_searchable
    end
    property :permission, predicate: ::RDF::QualifiedDC['rights#permissions']
  end

  begin
    LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
    LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
    LocalAuthority.register_vocabulary(self, "tag", "lc_genres")
  rescue
    puts "tables for vocabularies missing"
  end
end
