require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/ebucore', __FILE__)
require File.expand_path('../../../lib/rdf/relators', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
class VideoDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.description(:in => RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.alternate_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    #performer(s)
    map.performer(to: 'prf', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #director(s)
    map.director(to: 'drt', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #screenwriter(s)
    map.screenwriter(to: 'aus', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #Interviewer(s)
    map.interviewer(to: 'ivr', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #Interviewee(s)
    map.interviewee(to: 'ive', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #Speaker(s)
    map.speaker(to: 'spk', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #Producer(s)
    map.producer(to: 'pro', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    #Production Companies(s)
    map.production_company(to: 'prn', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    map.creator(to: 'creator', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.contributor(to: 'contributor', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.duration(to: 'duration', in: RDF::Ebucore)

    map.subject(to: 'subject', in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    map.genre(to: 'hasGenre', in: RDF::Ebucore) do |index|
      index.as :stored_searchable
    end

    map.language({in: RDF::DC}) do |index|
      index.as :searchable, :facetable
    end

    map.is_part_of({to: 'isPartOf', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    #date recorded
    map.date_created(to: 'created', :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.publisher({in: RDF::DC}) do |index|
      index.as :stored_searchable, :facetable
    end

    map.publication_date({to: 'issued', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.source(to: 'source', in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.alephIdentifier(:in =>RDF::ND) do |index|
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

    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    map.doi(to: 'identifier#doi', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.affiliation(to: 'creator#affiliation', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.rights(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end
    map.permission({in: RDF::QualifiedDC, to: 'rights#permissions'})
  end
end
