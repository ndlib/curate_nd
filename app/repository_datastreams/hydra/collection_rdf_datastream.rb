require 'active_fedora'
require File.expand_path('../../../../lib/rdf/qualified_dc', __FILE__)

module Hydra
  class CollectionRdfDatastream < ActiveFedora::NtriplesRDFDatastream
    map_predicates do |map|
      map.part_of(:to => "isPartOf", :in => RDF::DC)
      map.contributor(:in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.creator(:in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.title(:in => RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.description(:in => RDF::DC) do |index|
        index.type :text
        index.as :stored_searchable
      end
      map.publisher(:in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
        index.as :stored_searchable, :facetable
      end

      map.curator(to: 'contributor#curator', in: RDF::QualifiedDC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.date(:in => RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.date_created(:to => "created", :in => RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.date_uploaded(:to => "dateSubmitted", :in => RDF::DC) do |index|
        index.type :date
        index.as :stored_sortable
      end
      map.date_modified(:to => "modified", :in => RDF::DC) do |index|
        index.type :date
        index.as :stored_sortable
      end
      map.subject(:in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.language(:in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.rights(:in => RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.resource_type(:to => "type", :in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.identifier(:in => RDF::DC) do |index|
        index.as :stored_searchable
      end
      map.based_near(:in => RDF::FOAF) do |index|
        index.as :stored_searchable, :facetable
      end
      map.tag(:to => "relation", :in => RDF::DC) do |index|
        index.as :stored_searchable, :facetable
      end
      map.related_url(:to => "seeAlso", :in => RDF::RDFS)

      map.source({in: RDF::DC})
    end
  end
end
