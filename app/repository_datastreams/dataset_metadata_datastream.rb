require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
class DatasetMetadataDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.affiliation(to: 'creator#affiliation', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.organization(to: 'creator#organization', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_created(:to => 'created', :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.publication_date({to: 'issued', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.description(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.methodology(to: 'description#methodology', in: RDF::QualifiedDC)

    map.data_processing(to: 'description#data_processing', in: RDF::QualifiedDC)

    map.file_structure(to: 'description#file_structure', in: RDF::QualifiedDC)

    map.variable_list(to: 'description#variable_list', in: RDF::QualifiedDC)

    map.code_list(to: 'description#code_list', in: RDF::QualifiedDC)

    map.temporal_coverage({in: RDF::DC, to: 'temporal'})

    map.spatial_coverage({in: RDF::DC, to: 'spatial'})

    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    map.doi(to: "identifier#doi", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.permission(to: 'rights#permissions', in: RDF::QualifiedDC)

    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor_institution(to: 'contributor#institution', in: RDF::QualifiedDC)

    map.source({in: RDF::DC})

    map.language({in: RDF::DC}) do |index|
      index.as :searchable, :facetable
    end

    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    map.recommended_citation({in: RDF::DC, to: 'bibliographicCitation'})

    map.repository_name(to: "contributor#repository", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.collection_name(to: "relation#ispartof", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.size({to: "format#extent", in: RDF::QualifiedDC})

    map.requires({in: RDF::DC})

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.alephIdentifier(:in =>RDF::ND) do |index|
      index.as :stored_searchable
    end
  end
end
