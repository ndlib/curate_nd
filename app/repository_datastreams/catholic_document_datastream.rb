require File.expand_path('../../../lib/rdf/qualified_dc', __FILE__)
require File.expand_path('../../../lib/rdf/relators', __FILE__)
require File.expand_path('../../../lib/rdf/nd', __FILE__)
class CatholicDocumentDatastream < ActiveFedora::NtriplesRDFDatastream
  map_predicates do |map|

    # Title
    map.title(in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    # Alternate Title
    map.alternate_title(to: 'alternative', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    # Description
    map.abstract(to: 'abstract', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    # Author
    map.creator(to: 'creator', in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    # Issued By
    map.issued_by(to: 'isb', in: RDF::Relators) do |index|
      index.as :stored_searchable
    end

    # Promulgated By
    map.promulgated_by(to: 'promulgatingBody', in: RDF::ND) do |index|
      index.as :stored_searchable
    end

    # Date Pubished
    map.date_issued(to: 'issued', in: RDF::DC) do |index|
      index.as :stored_searchable
    end

    # Date Issued
    map.date(to: 'date', in: RDF::DC)

    # Date Promulgated
    map.promulgated_date(to: 'valid', in: RDF::DC)

    #Subjects
    map.subject(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable, :facetable
    end

    # Number of pages
    map.extent(to: 'extent', in: RDF::DC)

    # Spacial Coverage
    map.spatial_coverage(to: 'spatial', in: RDF::DC)

    # Temporal Coverage
    map.temporal_coverage(to: 'temporal', in: RDF::DC)

    # Language
    map.language({in: RDF::DC}) do |index|
      index.as :searchable, :facetable
    end

    # Document Type
    map.type(in: RDF::DC) do |index|
      index.type :text
      index.as :stored_searchable
    end

    # Repository
    map.repository_name(to: 'creator#repository', in: RDF::QualifiedDC)

    # Publisher
    map.publisher({in: RDF::DC})

    # Source
    map.source({in: RDF::DC})
    # Rights Holder

    map.rights_holder(to: 'rightsHolder', in: RDF::DC)

    # Copyright Date
    map.copyright_date(to: 'dateCopyrighted', in: RDF::DC)

    # Requires
    map.requires({in: RDF::DC})

    # Standard metadata:
    # Departments & Units
    map.administrative_unit(to: 'creator#administrative_unit', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.affiliation(to: 'creator#affiliation', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.basic_identifier({to: 'identifier', in: RDF::DC}) do |index|
      index.as :stored_searchable
    end
    map.doi(to: 'identifier#doi', in: RDF::QualifiedDC) do |index|
      index.as :stored_searchable
    end

    map.rights(in: RDF::DC) do |index|
      index.as :stored_searchable, :facetable
    end

    map.date_uploaded(to: 'dateSubmitted', in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.date_modified(to: 'modified', in: RDF::DC) do |index|
      index.type :date
      index.as :stored_sortable
    end

    map.alephIdentifier(in: RDF::ND) do |index|
      index.as :stored_searchable
    end

    map.permission({in: RDF::QualifiedDC, to: 'rights#permissions'})
  end
end
