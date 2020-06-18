# See https://s3.amazonaws.com/VRA/ontology.html#
module RDF
  class VRACore < Vocabulary("http://purl.org/vra/")
    property :designer
    property :manufacturer
    property :printer
    property :hasTechnique
    property :material
    property :culturalContext
    property :depth
    property :diameter
    property :height
    property :length
    property :width
    property :weight
    property :wasPerformed
    property :wasPresented
    property :wasProduced
    property :planFor
    property :preparatoryFor
    property :printingPlateFor
    property :prototypeFor
    property :reliefFor
    property :replicaOf
    property :studyFor
    property :depicts
    property :imageOf
    property :derivedFrom
    property :facsimileOf
    property :mateOf
    property :partnerInSetWith
    property :wasAlteration
    property :wasCommission
    property :wasDesigned
    property :wasDestroyed
    property :wasDiscovered
    property :wasRestored
    property :placeOfCreation
    property :placeOfDiscovery
    property :placeOfExhibition
    property :placeOfInstallation
    property :placeOfPublication
    property :placeOfRepository
    property :placeOfSite
  end
end
