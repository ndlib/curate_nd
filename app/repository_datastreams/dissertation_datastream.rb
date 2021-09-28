require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/etd_ms', __FILE__)
require File.expand_path('../../../lib/rdf/relators', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
class DissertationDatastream < ActiveFedora::NtriplesRDFDatastream

  map_predicates do |map|

    map.type(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.alternate_title(to: "title#alternate", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.creator(in: RDF::DC) do |index|
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

    map.degree_discipline(to: 'discipline', in: RDF::EtdMs) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.advisor(in: RDF::Relators, to: 'ths')

    map.abstract(to: "description#abstract", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.publisher(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.rights(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.format(in: RDF::QualifiedDC, to: 'format#mimetype')

    map.date_created(:to => "date#created", :in => RDF::QualifiedDC) do |index|
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

    map.date(to: "date", in: RDF::DC) do |index|
      index.as :stored_sortable
    end

    map.date_approved(to: "date#approved", in: RDF::QualifiedDC) do |index|
      index.as :stored_sortable
    end

    map.language(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coverage_spatial(to: "coverage#spatial", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.coverage_temporal(to: "coverage#temporal", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end
 
    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    map.doi(to: "identifier#doi", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    map.country(in: RDF::QualifiedDC, to: 'publisher#country')

    map.contributor(in: RDF::DC, class_name: 'Contributor')

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.alephIdentifier(:in =>RDF::ND) do |index|
      index.as :stored_searchable
    end
    map.permission({in: RDF::QualifiedDC, to: 'rights#permissions'})
  end

  accepts_nested_attributes_for :contributor
  class Contributor
    include ActiveFedora::RdfObject

    map_predicates do |map|
      map.contributor(in: RDF::DC) do |index|
        index.type :text
        index.as :stored_searchable
      end

      map.role(in: RDF::EtdMs) do |index|
        index.type :text
        index.as :stored_searchable
      end
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
