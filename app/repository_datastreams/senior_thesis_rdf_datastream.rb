require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
class SeniorThesisRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable, :displayable
    end

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :displayable
    end

    map.advisor(to: "contributor#advisor", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :displayable
    end

    map.created(in: RDF::DC)

    map.creator(in: RDF::DC) do |index|
      index.as :stored_searchable, :displayable
    end

    map.description(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :displayable
    end

    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :displayable, :facetable
    end

    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_uploaded(to: "dateSubmitted", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_searchable, :displayable, :sortable
    end

    map.date_created(:to => "created", :in => RDF::DC) do |index|
      index.type :date
      index.as :stored_searchable, :displayable
    end

    map.date_modified(to: "modified", in: RDF::DC) do |index|
      index.type :date
      index.as :stored_searchable, :displayable, :sortable
    end

    map.issued({in: RDF::DC}) do |index|
      index.as :stored, :displayable
    end

    map.available({in: RDF::DC})

    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :displayable, :facetable
    end

    map.bibliographic_citation({in: RDF::DC, to: 'bibliographicCitation'})

    map.source({in: RDF::DC})

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :displayable, :facetable
    end

    map.access_rights({in: RDF::DC, to: 'accessRights'})

    map.language({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.resource_type({in: RDF::DC, to: "type"}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.content_format({in: RDF::DC, to: 'format'})

    map.extent({in: RDF::DC})

    map.requires({in: RDF::DC})

    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    map.doi(to: "identifier#doi", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.part(:to => "hasPart", in: RDF::DC)

    map.alephIdentifier(:in =>RDF::ND) do |index|
      index.as :stored_searchable
    end
    map.permission({in: RDF::QualifiedDC, to: 'rights#permissions'})
  end
end
