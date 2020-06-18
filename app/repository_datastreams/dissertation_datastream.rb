require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/etd_ms', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"

class DissertationDatastream < ActiveFedora::NtriplesRDFDatastream

  property :mime_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end

  property :alternate_title, predicate: ::RDF::QualifiedDC['title#alternate'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
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

  property :degree_discipline, predicate: ::RDF::EtdMs.discipline do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :advisor, predicate: ::RDF::Vocab::MARCRelators.ths

  property :abstract, predicate: ::RDF::QualifiedDC['description#abstract'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end

  property :format, predicate: ::RDF::QualifiedDC['format#mimetype'.to_sym]

  property :date_created, predicate: ::RDF::QualifiedDC['date#created'.to_sym] do |index|
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

  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :stored_sortable
  end

  property :date_approved, predicate: ::RDF::QualifiedDC['date#approved'.to_sym] do |index|
    index.as :stored_sortable
  end

  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :stored_searchable, :facetable
  end

  property :coverage_spatial, predicate: ::RDF::QualifiedDC['coverage#spatial'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :coverage_temporal, predicate: ::RDF::QualifiedDC['coverage#temporal'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :stored_searchable,:facetable
  end

  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :country, predicate: ::RDF::QualifiedDC['publisher#country'.to_sym]

  # map.contributor(in: RDF::DC, class_name: 'Contributor')
  # will this work????
  property :contributor, predicate: ::RDF::Vocab::DC.contributor, class_name: 'Contributor'

  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end

  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end

  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]

  accepts_nested_attributes_for :contributor

  class Contributor < ActiveTriples::Resource

    property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
      index.type :text
      index.as :stored_searchable
    end

    property :role, predicate: ::RDF::EtdMs.role do |index|
      index.type :text
      index.as :stored_searchable
    end

    def persisted?
      rdf_subject.present?
    end

    def id
      rdf_subject.to_s if persisted?
    end

    def human_readable
      "#{self.contributor}, #{self.role}"
    end
  end
end
