require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"
class VideoDatastream < ActiveFedora::NtriplesRDFDatastream
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end

  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end

  #performer(s)
  property :performer, predicate: ::RDF::Vocab::MARCRelators.prf do |index|
    index.as :stored_searchable
  end

  #director(s)
  property :director, predicate: ::RDF::Vocab::MARCRelators.drt do |index|
    index.as :stored_searchable
  end

  #screenwriter(s)
  property :screenwriter, predicate: ::RDF::Vocab::MARCRelators.aus do |index|
    index.as :stored_searchable
  end

  #Interviewer(s)
  property :interviewer, predicate: ::RDF::Vocab::MARCRelators.ivr do |index|
    index.as :stored_searchable
  end

  #Interviewee(s)
  property :interviewee, predicate: ::RDF::Vocab::MARCRelators.ive do |index|
    index.as :stored_searchable
  end

  #Speaker(s)
  property :speaker, predicate: ::RDF::Vocab::MARCRelators.spk do |index|
    index.as :stored_searchable
  end

  #Producer(s)
  property :producer, predicate: ::RDF::Vocab::MARCRelators.pro do |index|
    index.as :stored_searchable
  end

  #Production Companies(s)
  property :production_company, predicate: ::RDF::Vocab::MARCRelators.prn do |index|
    index.as :stored_searchable
  end

  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end

  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :facetable
  end

  property :duration, predicate: ::RDF::Vocab::EBUCore.duration

  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end

  property :genre, predicate: ::RDF::Vocab::EBUCore.hasGenre do |index|
    index.as :stored_searchable
  end

  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :searchable, :facetable
  end

  property :is_part_of, predicate: ::RDF::Vocab::DC.isPartOf do |index|
    index.as :stored_searchable
  end

  #date recorded
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end

  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end

  property :publication_date, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :stored_searchable
  end

  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.type :text
    index.as :stored_searchable
  end

  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end

  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
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

  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end

  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end

  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
end
