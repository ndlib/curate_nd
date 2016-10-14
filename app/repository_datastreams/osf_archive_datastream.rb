require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
class OsfArchiveDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|
    map.creator(to: 'creator', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.title(to: 'title', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.source(to: 'source', in: RDF::DC)

    map.subject(to: 'subject', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.type(in: RDF::DC)

    map.language(to: 'language', in: RDF::DC)

    map.affiliation(to: 'creator#affiliation', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.description(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.date_created(to: 'created', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_modified(to: 'modified', in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_archived(to: 'dateSubmitted', in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.rights(to: 'rights', in: RDF::DC)

    map.doi(to: 'identifier#doi', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end
  end
end
