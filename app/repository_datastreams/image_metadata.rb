require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/image', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/nd', __FILE__)
require File.expand_path('../../../lib/rdf/vocab/vracore', __FILE__)
require "rdf/vocab"

class ImageMetadata < ActiveFedora::NtriplesRDFDatastream

  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end
  property :alternate_title, predicate: ::RDF::Vocab::DC.alternative do |index|
    index.as :stored_searchable
  end
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end
  property :affiliation, predicate: ::RDF::QualifiedDC['creator#affiliation'] do |index|
    index.as :stored_searchable, :facetable
  end
  property :organization, predicate: ::RDF::QualifiedDC['creator#organization'] do |index|
    index.as :stored_searchable, :facetable
  end
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'] do |index|
    index.as :stored_searchable, :facetable
  end
  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :facetable
  end
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable, :facetable
  end
  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.as :stored_searchable
  end
  property :source, predicate: ::RDF::Vocab::DC.source
  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end
  property :rights, predicate: ::RDF::Vocab::DC.rights do |index|
    index.as :stored_searchable
  end
  property :format, predicate: ::RDF::QualifiedDC['format#mimetype']
  property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_sortable
  end
  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_sortable
  end
  property :identifier, predicate: ::RDF::QualifiedDC['identifier#doi'] do |index|
    index.as :stored_searchable,:facetable
  end
  property :doi, predicate: ::RDF::QualifiedDC['identifier#doi']
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.as :stored_searchable, :facetable
  end
  property :type, predicate: ::RDF::Vocab::DC.type
  property :recommended_citation, predicate: ::RDF::QualifiedDC['bibliographicCitation']
  property :spatial_coverage, predicate: ::RDF::Vocab::DC.spatial do |index|
    index.as :stored_searchable
  end
  property :temporal_coverage, predicate: ::RDF::Vocab::DC.temporal do |index|
    index.as :stored_searchable
  end
  property :language, predicate: ::RDF::Vocab::DC.language
  property :size, predicate: ::RDF::QualifiedDC['format#extent']
  property :date_digitized, predicate: ::RDF::QualifiedDC['date#digitized']
  property :digitizing_equipment, predicate: ::RDF::QualifiedDC['description#technical']
  property :contributor_institution, predicate: ::RDF::QualifiedDC['contributor#institution'] do |index|
    index.as :stored_searchable
  end
  property :requires, predicate: ::RDF::Vocab::DC.requires
  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :alephIdentifier, predicate: ::RDF::ND.alephIdentifier do |index|
    index.as :stored_searchable
  end
  property :vra_designer, predicate: ::RDF::VRACore.designer do |index|
  	index.as :stored_searchable
  end
  property :vra_manufacturer, predicate: ::RDF::VRACore.manufacturer do |index|
  	index.as :stored_searchable
  end
  property :vra_printer, predicate: ::RDF::VRACore.printer do |index|
  	index.as :stored_searchable
  end
  property :vra_has_technique, predicate: ::RDF::VRACore.hasTechnique do |index|
  	index.as :stored_searchable
  end
  property :vra_material, predicate: ::RDF::VRACore.material do |index|
  	index.as :stored_searchable
  end
  property :vra_cultural_context, predicate: ::RDF::VRACore.culturalContext do |index|
  	index.as :stored_searchable
  end
  property :is_part_of, predicate: ::RDF::Vocab::DC.isPartOf do |index|
  	index.as :stored_searchable
  end
  property :s_version_of, predicate: ::RDF::Vocab::DC.isVersionOf
  property :vra_depth, predicate: ::RDF::VRACore.depth
  property :vra_diameter, predicate: ::RDF::VRACore.diameter
  property :vra_height, predicate: ::RDF::VRACore.height
  property :vra_length, predicate: ::RDF::VRACore.length
  property :vra_width, predicate: ::RDF::VRACore.width
  property :vra_weight, predicate: ::RDF::VRACore.weight
  property :vra_was_performed, predicate: ::RDF::VRACore.wasPerformed
  property :vra_was_presented, predicate: ::RDF::VRACore.wasPresented
  property :vra_was_produced, predicate: ::RDF::VRACore.wasProduced
  property :date_issued, predicate: ::RDF::Vocab::DC.issued
  property :vra_plan_for, predicate: ::RDF::VRACore.planFor do |index|
  	index.as :stored_searchable
  end
  property :vra_preparatory_for, predicate: ::RDF::VRACore.preparatoryFor do |index|
  	index.as :stored_searchable
  end
  property :vra_printing_plate_for, predicate: ::RDF::VRACore.printingPlateFor do |index|
  	index.as :stored_searchable
  end
  property :vra_prototype_for, predicate: ::RDF::VRACore.prototypeFor do |index|
  	index.as :stored_searchable
  end
  property :vra_relief_for, predicate: ::RDF::VRACore.reliefFor do |index|
  	index.as :stored_searchable
  end
  property :vra_replica_of, predicate: ::RDF::VRACore.replicaOf do |index|
  	index.as :stored_searchable
  end
  property :vra_study_for, predicate: ::RDF::VRACore.studyFor do |index|
  	index.as :stored_searchable
  end
  property :vra_depicts, predicate: ::RDF::VRACore.depicts do |index|
  	index.as :stored_searchable
  end
  property :vra_image_of, predicate: ::RDF::VRACore.imageOf do |index|
  	index.as :stored_searchable
  end
  property :vra_derived_from, predicate: ::RDF::VRACore.derivedFrom do |index|
  	index.as :stored_searchable
  end
  property :vra_facsimile_of, predicate: ::RDF::VRACore.facsimileOf do |index|
  	index.as :stored_searchable
  end
  property :vra_mate_of, predicate: ::RDF::VRACore.mateOf
  property :vra_partner_in_set_with, predicate: ::RDF::VRACore.partnerInSetWith
  property :vra_was_alteration, predicate: ::RDF::VRACore.wasAlteration
  property :vra_was_commission, predicate: ::RDF::VRACore.wasCommission
  property :vra_was_designed, predicate: ::RDF::VRACore.wasDesigned
  property :vra_was_destroyed, predicate: ::RDF::VRACore.wasDestroyed
  property :vra_was_discovered, predicate: ::RDF::VRACore.wasDiscovered
  property :vra_was_restored, predicate: ::RDF::VRACore.wasRestored
  property :vra_place_of_creation, predicate: ::RDF::VRACore.placeOfCreation do |index|
  	index.as :stored_searchable
  end
  property :vra_place_of_discovery, predicate: ::RDF::VRACore.placeOfDiscovery do |index|
  	index.as :stored_searchable
  end
  property :vra_place_of_exhibition, predicate: ::RDF::VRACore.placeOfExhibition do |index|
  	index.as :stored_searchable
  end
  property :vra_place_of_installation, predicate: ::RDF::VRACore.placeOfInstallation do |index|
  	index.as :stored_searchable
  end
  property :vra_place_of_publication, predicate: ::RDF::VRACore.placeOfPublication
  property :vra_place_of_repository, predicate: ::RDF::VRACore.placeOfRepository do |index|
  	index.as :stored_searchable
  end
  property :vra_place_of_site, predicate: ::RDF::VRACore.placeOfSite do |index|
  	index.as :stored_searchable
  end
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions']
end
