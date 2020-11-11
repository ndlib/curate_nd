# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
require File.expand_path('../../../lib/rdf/vocab/qualified_dc', __FILE__)
require "rdf/vocab"
class LibraryCollectionRdfDatastream < ActiveFedora::NtriplesRDFDatastream
  property :part_of, predicate: ::RDF::Vocab::DC.isPartOf
  property :contributor, predicate: ::RDF::Vocab::DC.contributor do |index|
    index.as :stored_searchable, :facetable
  end
  property :creator, predicate: ::RDF::Vocab::DC.creator do |index|
    index.as :stored_searchable, :facetable
  end
  property :title, predicate: ::RDF::Vocab::DC.title do |index|
    index.as :stored_searchable
  end
  property :description, predicate: ::RDF::Vocab::DC.description do |index|
    index.type :text
    index.as :stored_searchable
  end
  property :publisher, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable, :facetable
  end
  property :date_created, predicate: ::RDF::Vocab::DC.created do |index|
    index.as :stored_searchable
  end
  property :date_uploaded, predicate: ::RDF::Vocab::DC.dateSubmitted do |index|
    index.type :date
    index.as :stored_sortable
  end
  property :date_modified, predicate: ::RDF::Vocab::DC.modified do |index|
    index.type :date
    index.as :stored_sortable
  end
  property :subject, predicate: ::RDF::Vocab::DC.subject do |index|
    index.as :stored_searchable, :facetable
  end
  property :language, predicate: ::RDF::Vocab::DC.language do |index|
    index.as :stored_searchable, :facetable
  end
  property :rights, predicate: ::RDF::Vocab::DC.publisher do |index|
    index.as :stored_searchable
  end
  property :resource_type, predicate: ::RDF::Vocab::DC.type do |index|
    index.as :stored_searchable, :facetable
  end
  property :identifier, predicate: ::RDF::Vocab::DC.identifier do |index|
    index.as :stored_searchable
  end
  property :temporal, predicate: ::RDF::Vocab::DC.temporal do |index|
    index.as :stored_searchable
  end
  property :spatial, predicate: ::RDF::Vocab::DC.spatial do |index|
    index.as :stored_searchable
  end
  property :based_near, predicate: ::RDF::Vocab::FOAF.based_near do |index|
    index.as :stored_searchable, :facetable
  end
  property :relation, predicate: ::RDF::Vocab::DC.relation do |index|
    index.as :stored_searchable, :facetable
  end
  property :related_url, predicate: ::RDF::RDFS.seeAlso
  property :administrative_unit, predicate: ::RDF::QualifiedDC['creator#administrative_unit'] do |index|
    index.as :stored_searchable, :facetable
  end
  property :source, predicate: ::RDF::Vocab::DC.source
  property :curator, predicate: ::RDF::QualifiedDC['contributor#curator'] do |index|
    index.as :stored_searchable, :facetable
  end
  property :date, predicate: ::RDF::Vocab::DC.date do |index|
    index.as :stored_searchable
  end
  property :permission, predicate: ::RDF::QualifiedDC['rights#permissions']
end
