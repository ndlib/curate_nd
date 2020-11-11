class BatchRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  property :title, predicate: ::RDF::Vocab::DC.title
  property :part, predicate: ::RDF::Vocab::DC.hasPart
  property :creator, predicate: ::RDF::Vocab::DC.creator
  property :status, predicate: ::RDF::Vocab::DC.type
end
