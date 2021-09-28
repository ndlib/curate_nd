require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/image', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
require File.expand_path('../../../lib/rdf/bibo', __FILE__)
require File.expand_path('../../../lib/rdf/vracore', __FILE__)
class ImageMetadata < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.alternate_title(to: 'alternative', in: RDF::DC) do |index|
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

    map.contributor(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_created(:to => "created", :in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.description(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.source(in: RDF::DC)

    map.publisher(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.rights(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    map.format(in: RDF::QualifiedDC, to: 'format#mimetype')

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
    map.doi(to: "identifier#doi", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.subject(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.type(in: RDF::DC)

    map.recommended_citation({in: RDF::DC, to: 'bibliographicCitation'})

    map.spatial_coverage({to: "spatial", in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.temporal_coverage({to: "temporal", in: RDF::DC}) do |index|
      index.as :stored_searchable
    end

    map.language(in: RDF::DC)

    map.size({to: "format#extent", in: RDF::QualifiedDC})

    map.date_digitized(to: 'date#digitized', in: RDF::QualifiedDC)

    map.digitizing_equipment(to: 'description#technical', in: RDF::QualifiedDC)

    map.contributor_institution(to: "contributor#institution", in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.requires({in: RDF::DC})

    map.relation(:in => RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.alephIdentifier(:in =>RDF::ND) do |index|
      index.as :stored_searchable
    end

    map.vra_designer({to: 'designer', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_manufacturer({to: 'manufacturer', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_printer({to: 'printer', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_has_technique({to: 'hasTechnique', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_material({to: 'material', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_cultural_context({to: 'culturalContext', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.is_part_of({to: 'isPartOf', in: RDF::DC}) do |index|
    	index.as :stored_searchable
    end

    map.is_version_of({to: 'isVersionOf', in: RDF::DC})

    map.vra_depth({to: 'depth', in: RDF::VRACore})

    map.vra_diameter({to: 'diameter', in: RDF::VRACore})

    map.vra_height({to: 'height', in: RDF::VRACore})

    map.vra_length({to: 'length', in: RDF::VRACore})

    map.vra_width({to: 'width', in: RDF::VRACore})

    map.vra_weight({to: 'weight', in: RDF::VRACore})

    map.vra_was_performed({to: 'wasPerformed', in: RDF::VRACore})

    map.vra_was_presented({to: 'wasPresented', in: RDF::VRACore})

    map.vra_was_produced({to: 'wasProduced', in: RDF::VRACore})

    map.date_issued ({ to: 'issued', in: RDF::DC})

    map.vra_plan_for({to: 'planFor', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_preparatory_for({to: 'preparatoryFor', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_printing_plate_for({to: 'printingPlateFor', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_prototype_for({to: 'prototypeFor', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_relief_for({to: 'reliefFor', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_replica_of({to: 'replicaOf', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_study_for({to: 'studyFor', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_depicts({to: 'depicts', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_image_of({to: 'imageOf', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_derived_from({to: 'derivedFrom', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_facsimile_of({to: 'facsimileOf', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_mate_of({to: 'mateOf', in: RDF::VRACore})

    map.vra_partner_in_set_with({to: 'partnerInSetWith', in: RDF::VRACore})

    map.vra_was_alteration({to: 'wasAlteration', in: RDF::VRACore})

    map.vra_was_commission({to: 'wasCommission', in: RDF::VRACore})

    map.vra_was_designed({to: 'wasDesigned', in: RDF::VRACore})

    map.vra_was_destroyed({to: 'wasDestroyed', in: RDF::VRACore})

    map.vra_was_discovered({to: 'wasDiscovered', in: RDF::VRACore})

    map.vra_was_restored({to: 'wasRestored', in: RDF::VRACore})

    map.vra_place_of_creation({to: 'placeOfCreation', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_place_of_discovery({to: 'placeOfDiscovery', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_place_of_exhibition({to: 'placeOfExhibition', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_place_of_installation({to: 'placeOfInstallation', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_place_of_publication({to: 'placeOfPublication', in: RDF::VRACore})

    map.vra_place_of_repository({to: 'placeOfRepository', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.vra_place_of_site({to: 'placeOfSite', in: RDF::VRACore}) do |index|
    	index.as :stored_searchable
    end

    map.permission({in: RDF::QualifiedDC, to: 'rights#permissions'})
  end
end
