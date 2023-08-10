require 'spec_helper'

module Doi
  RSpec.describe Datacite do
    let(:subject) { Doi::Datacite }
    let(:curation_concern) { instance_double(ActiveFedora::Base) }
    let(:response) { double(RestClient::Response, 
      body: '{ "data": { "id": "10.xxxx/987654336" }}')}

    describe '#mint' do
      let(:minted_doi) { Doi::Datacite.mint(curation_concern) }
      context 'minting a doi' do
        before do
          allow(RestClient::Request).to receive(:execute).and_return(response)
        end
        it 'mints a DOI via a request to the DOI hosting service and prepends identifier with "doi:"' do
          expect(DataciteMapper).to receive(:call).with(curation_concern)
          expect(RestClient::Request).to receive(:execute)
          expect(minted_doi).to start_with('doi:')
        end
      end
      context 'with errors' do
        let(:doi_request_object) { { id: 1 } }
        before do
          allow(RestClient::Request).to receive(:execute).and_raise(RestClient::UnprocessableEntity)
          allow(DataciteMapper).to receive(:call).with(curation_concern).and_return(doi_request_object)
        end
        it 'reports RestClient errors' do

          minted_doi
        end
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
        ["https://doi.org/10.1002/ppsc.201700420", "doi:10.1002/ppsc.201700420"],
        ["https://doi.org/10.1002/ppsc.201700420", "doi:10.1002/ppsc.201700420"],
        ["https://doi.org/10.1002/12310.56789/abc", "doi:10.1002/12310.56789/abc"]
      ].each do |given, expected|
        it "normalizes a doi" do
          expect(subject.normalize_identifier(given)).to eq(expected)
        end
      end
    end

    describe '#remote_uri_for' do
      it 'concatenates the resolver url defined in the env with the identifier given' do
        expect(subject.remote_uri_for('doi:10.25626/abc123').to_s).to eq("#{ENV.fetch('DOI_RESOLVER')}/10.25626/abc123")
      end
    end
  end
end
