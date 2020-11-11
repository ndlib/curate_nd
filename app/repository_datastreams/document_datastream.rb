require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require "rdf/vocab"

class DocumentDatastream < ActiveFedora::NtriplesRDFDatastream

# base attributes
  property :type, predicate: ::RDF::Vocab::DC.type do |index|
    index.type :text
    index.as :stored_searchable
  end
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end
  property :abstract, predicate: ::RDF::Vocab::DC.abstract do |index|
    index.as :stored_searchable
  end
  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end
  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.type :text
    index.as :stored_searchable, :facetable
  end
  property :source, predicate: ::RDF::Vocab::DC.source
  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :searchable, :facetable
  end
  property :temporal_coverage, predicate: ::RDF::Vocab::DC.temporal do |index|
    index.as :stored_searchable
  end
  property :spatial_coverage, predicate: ::RDF::Vocab::DC.spatial do |index|
    index.as :stored_searchable
  end
  property :size, predicate: ::RDF::QualifiedDC['format#extent'.to_sym]
  property :requires, predicate: ::RDF::Vocab::DC.requires
  property :repository_name, predicate: ::RDF::QualifiedDC['contributor#repository'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :collection_name, predicate: ::RDF::QualifiedDC['relation#ispartof'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :contributor_institution, predicate: ::RDF::QualifiedDC['contributor#institution'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :recommended_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym]
  property :identifier, predicate: ::RDF::QualifiedDC['identifier#doi'.to_sym] do |index|
    index.as :stored_searchable,:facetable
  end
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions'.to_sym]
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

# "Book" only attributes
  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end
  property :author, predicate: ::RDF::QualifiedDC['creator#author'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :coauthor, predicate: ::RDF::QualifiedDC['contributor#author'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :editor, predicate: ::RDF::QualifiedDC['creator#editor'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :contributing_editor, predicate: ::RDF::QualifiedDC['contributor#editor'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :artist, predicate: ::RDF::QualifiedDC['creator#artist'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :contributing_artist, predicate: ::RDF::QualifiedDC['contributor#artist'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :illustrator, predicate: ::RDF::QualifiedDC['creator#illustrator'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :contributing_illustrator, predicate: ::RDF::QualifiedDC['contributor#illustrator'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :photographer, predicate: ::RDF::QualifiedDC['creator#photographer'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :contributing_photographer, predicate: ::RDF::QualifiedDC['contributor#photographer'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :event_speaker, predicate: ::RDF::QualifiedDC['contributor#speaker'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end
  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :facetable
  end
  property :copyright_date, predicate: ::RDF::Vocab::DC.dateCopyrighted
  property :table_of_contents, predicate: ::RDF::QualifiedDC['description#table_of_contents'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :extent, predicate: ::RDF::Vocab::DC.extent
  property :isbn, predicate: ::RDF::QualifiedDC['identifier#isbn'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :local_identifier, predicate: ::RDF::QualifiedDC['identifier#local'.to_sym] do |index|
    index.as :stored_searchable
  end
  property :publication_date, predicate: ::RDF::Vocab::DC.issued do |index|
    index.as :stored_searchable
  end
  property :edition, predicate: ::RDF::QualifiedDC['isVersionOf#edition'.to_sym]
  property :lc_subject, predicate: ::RDF::QualifiedDC['subject#lcsh'.to_sym] do |index|
    index.as :stored_searchable
  end

# apparently unused(?)
  property :format, predicate: ::RDF::QualifiedDC['format#mimetype'.to_sym]
  property :organization, predicate: ::RDF::QualifiedDC['creator#organization'.to_sym] do |index|
    index.as :stored_searchable, :facetable
  end
  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end
end
