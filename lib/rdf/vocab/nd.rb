# See https://github.com/structureddynamics/Bibliographic-Ontology-BIBO
module RDF
  class ND < Vocabulary("https://library.nd.edu/ns/terms/")
    property :alephIdentifier
    property :osfProjectIdentifier, comment: "The identifier of the source OSF Project. Extends dc:identifier."
    property :promulgatingBody
  end
end
