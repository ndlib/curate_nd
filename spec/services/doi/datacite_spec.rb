require 'spec_helper'

module Doi
  RSpec.describe Datacite do
    let(:datacite_identifier) { {"data"=>{"id"=>"10.81068/987654336", "type"=>"dois", "attributes"=>{"doi"=>"10.81068/987654336", "prefix"=>"10.81068", "suffix"=>"987654336", "creators"=>[{"name"=>"Mark Suhovecky"}], "titles"=>[{"title"=>"DOI MAdness PArt Two"}], "publisher"=>"Curate ND", "publicationYear"=>2021, "types"=>{"schemaOrg"=>"ScholarlyArticle", "citeproc"=>"article-journal", "bibtex"=>"article", "ris"=>"RPRT", "resourceTypeGeneral"=>"Text"}, "url"=>"https://curate.nd.edu/show/987654336", "metadataVersion"=>0, "created"=>"2021-10-18T21:07:37.000Z", "registered"=>"2021-10-18T21:07:37.000Z", "published"=>"2021", "updated"=>"2021-10-18T21:07:37.000Z"}}}}
    let(:remapped_hash)  {  { "data": { "type": "dois", "attributes": { "event": "publish", "doi": "10.81068/987654336", "publisher": "Curate ND", "creators": [{ "name": "Mark Suhovecky" }], "titles": [{ "title": "DOI MAdness PArt Two" }], "publicationYear": 2021, "types": { "resourceTypeGeneral": "Text" }, "url": "https://curate.nd.edu/show/987654336" } } } }
    let(:curation_concern) { instance_double(ActiveFedora::Base) }
    let(:subject) { Doi::Datacite }

    describe '#mint' do
      it 'Returns the id given by DOI:Datacite::create_doi' do
        allow(DataciteMapper).to receive(:call).and_return(remapped_hash)
        allow(subject).to receive(:create_doi).with(remapped_hash).and_return( "doi:" + datacite_identifier['data']['id'])
        expect(subject.mint(curation_concern)).to eq('doi:10.81068/987654336')
      end
    end

    describe '#normalize_identifier' do
      [
        ["#{ENV.fetch('DOI_RESOLVER')}/doi:10.123", 'doi:10.123'],
        ["10.25626/abc123", 'doi:10.25626/abc123'],
        [" doi:10.25626/abc123", 'doi:10.25626/abc123'],
        ["doi:10.25626/abc123 ", 'doi:10.25626/abc123'],
        ["doi: 10.25626/abc123", 'doi:10.25626/abc123'],
        ["doi: 10.25626 / abc123", 'doi:10.25626/abc123'],
        ['https://doi:10.123/abc', 'doi:10.123/abc'],
        ["https://doi.org/10.1002/ppsc.201700420", "doi:10.1002/ppsc.201700420"]
      ].each do |given, expected|
        it "normalizes #{given.inspect} to #{expected.inspect}" do
          expect(subject.normalize_identifier(given)).to eq(expected)
        end
      end
    end

    describe '#remote_uri_for' do
      it 'concatenates the resolver url defined in the env with the identifier given' do
        expect(subject.remote_uri_for('doi:10.25626/abc123').to_s).to eq("#{ENV.fetch('DOI_RESOLVER')}/doi:10.25626/abc123")
      end
    end
  end
end
