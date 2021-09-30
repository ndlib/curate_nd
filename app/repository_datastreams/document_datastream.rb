require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)

class DocumentDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

  # base attributes
    map.type(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.abstract(to: 'abstract', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.affiliation(to: 'creator#affiliation', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_created(:to => 'created', :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    map.source({in: RDF::DC})

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.language({in: RDF::DC}) do |index|
      index.as :searchable, :facetable
    end

    map.temporal_coverage(to: 'temporal', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.spatial_coverage(to: 'spatial', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.size(to: 'format#extent', in: RDF::QualifiedDC)

    map.requires({in: RDF::DC})

    map.repository_name(to: 'contributor#repository', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.collection_name(to: 'relation#ispartof', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.contributor_institution(to: 'contributor#institution', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.recommended_citation(to: 'bibliographicCitation', in: RDF::DC)

    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    map.doi(to: "identifier#doi", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.permission(to: 'rights#permissions', in: RDF::QualifiedDC)

    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_uploaded(to: 'dateSubmitted', in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(to: 'modified', in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

  # "Book" only attributes
    map.alternate_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.author(to: 'creator#author', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coauthor(to: 'contributor#author', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.editor(to: 'creator#editor', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.contributing_editor(to: 'contributor#editor', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.artist(to: 'creator#artist', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.contributing_artist(to: 'contributor#artist', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.illustrator(to: 'creator#illustrator', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.contributing_illustrator(to: 'contributor#illustrator', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.photographer(to: 'creator#photographer', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.contributing_photographer(to: 'contributor#photographer', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.event_speaker(to: 'contributor#speaker', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.creator(to: 'creator', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor(to: 'contributor', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.copyright_date(to: 'dateCopyrighted', in: RDF::DC)

    map.table_of_contents(to: 'description#table_of_contents', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.extent(in: RDF::DC)

    map.isbn(to: 'identifier#isbn', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.local_identifier(to: 'identifier#local', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.publication_date(to: 'issued', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.edition(to: 'isVersionOf#edition', in: RDF::QualifiedDC)

    map.lc_subject(to: 'subject#lcsh', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

  # apparently unused(?)
    map.format(to: 'format#mimetype', in: RDF::QualifiedDC)

    map.organization(to: 'creator#organization', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.alephIdentifier(:in =>RDF::ND) do |index|
      index.as :stored_searchable
    end
  end
end
