require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/bibo', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
class ArticleMetadataDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.alternate_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.creator(to: 'creator#author', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.organization(to: 'creator#organization', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.affiliation(to: 'creator#affiliation', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor(to: 'contributor#author', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.repository_name(to: "contributor#repository", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.contributor_institution(to: "contributor#institution", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.collection_name(to: "relation#ispartof", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.abstract(to: 'abstract', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.volume(:in =>RDF::BIBO)

    map.issue(:in => RDF::BIBO)

    map.page_start({to: 'pageStart', in: RDF::BIBO})

    map.page_end({to: 'pageEnd', in: RDF::BIBO})

    map.num_pages({to: 'numPages', in: RDF::BIBO})

    map.isbn(:in => RDF::BIBO) do |index|
      index.as :stored_searchable
    end

    map.eIssn(:in => RDF::BIBO) do |index|
      index.as :stored_searchable
    end

    map.publication_date({to: 'issued', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.is_part_of({to: 'isPartOf', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.content_format({in: RDF::QualifiedDC, to: 'format#mimetype'})

    map.date_created(:to => 'created', :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.recommended_citation({in: RDF::DC, to: 'bibliographicCitation'})

    map.permission({in: RDF::QualifiedDC, to: 'rights#permissions'})

    map.language({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.spatial_coverage({to: "spatial", in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.temporal_coverage({to: "temporal", in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.requires({in: RDF::DC})

    map.size({to: "format#extent", in: RDF::QualifiedDC})

    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.doi(to: "identifier#doi", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.issn({to: 'identifier#issn', in: RDF::QualifiedDC})

    map.source(to: 'source', in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.subject(to: 'subject', in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    map.type(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.alephIdentifier(:in =>RDF::ND) do |index|
      index.as :stored_searchable
    end

  end
end
