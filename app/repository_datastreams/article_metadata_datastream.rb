require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"

class ArticleMetadataDatastream < ActiveFedora::NtriplesRDFDatastream

  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end
  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end
  property :creator, predicate: ::RDF::QualifiedDC['creator#author'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :organization, predicate: ::RDF::QualifiedDC['creator#organization'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'.to_sym] do |index|
      index.as :stored_searchable, :facetable
    end
  property :contributor, predicate: ::RDF::QualifiedDC['contributor#author'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :repository_name, predicate: ::RDF::QualifiedDC['contributor#repository'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :contributor_institution, predicate: ::RDF::QualifiedDC['contributor#institution'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :collection_name, predicate: ::RDF::QualifiedDC['relation#ispartof'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end
  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end
  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable, :facetable
  end
  property :volume, predicate: ::RDF::Vocab::BIBO.volume
  property :issue, predicate: ::RDF::Vocab::BIBO.issue
  property :page_start, predicate: ::RDF::Vocab::BIBO.pageStart
  property :page_end, predicate: ::RDF::Vocab::BIBO.pageEnd
  property :num_pages, predicate: ::RDF::Vocab::BIBO.numPages
  property :isbn, predicate: ::RDF::Vocab::BIBO.isbn do |index|
    index.as :stored_searchable
  end
  property :eIssn, predicate: ::RDF::Vocab::BIBO.eissn do |index|
    index.as :stored_searchable
  end
  property :publication_date, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :stored_searchable
  end
  property :is_part_of, predicate: ::RDF::Vocab::DC.isPartOf do |index|
    index.as :stored_searchable
  end
  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :content_format, predicate: ::RDF::QualifiedDC['format#mimetype'.to_sym]
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
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
  property :recommended_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :stored_searchable, :facetable
  end
  property :spatial_coverage, predicate: ::RDF::Vocab::DC.spatial do |index|
    index.as :stored_searchable
  end
  property :temporal_coverage, predicate: ::RDF::Vocab::DC.temporal do |index|
    index.as :stored_searchable
  end
  property :requires, predicate: ::RDF::Vocab::DC.requires
  property :size, predicate: ::RDF::QualifiedDC['format#extent'.to_sym]
  property :identifier, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym]
  property :issn, predicate: ::RDF::QualifiedDC['identifier#issn'.to_sym]
  property :source, predicate: ::RDF::Vocab::DC.source do |index|
    index.type :text
    index.as :stored_searchable
  end
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  property :type, predicate: ::RDF::Vocab::DC.type do |index|
    index.type :text
    index.as :stored_searchable
  end
  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end
end
