require File.expand_path('../../../lib/rdf/vocab/qualified_foaf', __FILE__)
require "rdf/vocab"

class PersonMetadataDatastream < ActiveFedora::NtriplesRDFDatastream

  property :name, predicate: ::RDF::FOAF.name do |index|
    index.as :stored_searchable
  end

  property :title, predicate: ::RDF::FOAF.title do |index|
    index.as :stored_searchable
  end

  property :campus_phone_number, predicate: ::RDF::QualifiedFOAF['phone#campus_phone_number'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :alternate_phone_number, predicate: ::RDF::QualifiedFOAF['phone#alternate_phone_number'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :date_of_birth, predicate: ::RDF::FOAF.birthday do |index|
    index.as :stored_searchable
  end

  property :personal_webpage, predicate: ::RDF::FOAF.homepage do |index|
    index.as :stored_searchable
  end

  property :blog, predicate: ::RDF::FOAF.weblog do |index|
    index.as :stored_searchable
  end

  property :gender, predicate: ::RDF::FOAF.gender do |index|
    index.as :stored_searchable
  end

  property :based_near, predicate: ::RDF::FOAF.based_near do |index|
    index.as :stored_searchable
  end

  property :alternate_email, predicate: ::RDF::QualifiedFOAF['account#alternate_email'.to_sym] do |index|
    index.as :stored_searchable
  end

  property :email, predicate:  ::RDF::QualifiedFOAF['account#preferred_email'.to_sym] do |index|
    index.as :stored_searchable
  end
end
