require 'spec_helper'
require 'nokogiri'

describe OaiController do
  let(:collection) { FactoryGirl.create(:library_collection) }
  let(:doc) { Nokogiri::XML.parse(response.body) }

  before do
    collection
    2.times do |j|
      FactoryGirl.create(:public_article)
    end
  end

  describe '#index' do
    context 'with no params' do
      let(:oai_params) {}
      let(:key) { 'error' }
      let(:attribute) { 'code' }
      let(:value) { doc.css(key).attr(attribute).value }

      it 'returns 200 with bad verb error' do
        get :index, oai_params
        expect(response).to be_successful
        expect(value).to eq('badVerb')
      end
    end

    context 'for verb Identify' do
      let(:oai_params) {{ verb: 'Identify' }}
      let(:key) { 'repositoryName' }

      it 'returns 200 with ' do
        get :index, oai_params
        expect(response).to be_successful
        expect(doc.css(key).text).to eq('CurateOaiProvider')
      end
    end

    context 'for verb GetRecord' do
      context 'without required params' do
        let(:oai_params) {{ verb: 'GetRecord' }}
        let(:key) { 'error' }
        let(:attribute) { 'code' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with bad argument error' do
          get :index, oai_params
          expect(response).to be_successful
          expect(value).to eq('badArgument')
        end
      end

      context 'with required params and metadataPrefix oai_dc' do
        let(:oai_params) { { verb: 'GetRecord', identifier: collection.id, metadataPrefix: 'oai_dc' } }
        let(:key) { 'request' }
        let(:attribute) { 'identifier' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with item metadata' do
          get :index, oai_params
          expect(response).to be_successful
          expect(value).to eq(collection.id)
        end
      end

      context 'with required params and metadataPrefix dcterms' do
        let(:oai_params) { { verb: 'GetRecord', identifier: collection.id, metadataPrefix: 'dcterms' } }
        let(:key) { 'request' }
        let(:attribute) { 'identifier' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with item metadata' do
          get :index, oai_params
          expect(response).to be_successful
          expect(value).to eq(collection.id)
        end
      end

      context 'with bad identifier' do
        let(:oai_params) { { verb: 'GetRecord', identifier: 'i_dont_exist', metadataPrefix: 'oai_dc' } }
        let(:key) { 'error' }
        let(:attribute) { 'code' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with ' do
          get :index, oai_params
          expect(response).to be_successful
          expect(value).to eq('idDoesNotExist')
        end
      end
    end

    context 'for verb ListSets' do
      let(:oai_params) {{ verb: 'ListSets' }}
      let(:key) { 'setName' }
      let(:value) { doc.css(key).to_ary.map(&:text) }
      let(:model_sets) { Curate.configuration.registered_curation_concern_types.sort.collect(&:constantize).map(&:to_s) }
      let(:collection_sets) { ["Collection: #{collection.title}"] }
      let(:primo_set) { ['Primo'] }
      let(:all_sets) { model_sets + collection_sets + primo_set }

      it 'returns 200 with all valid sets' do
        get :index, oai_params
        expect(response).to be_successful
        expect(value).to eq(all_sets)
      end
    end

    context 'for verb ListIdentifiers' do
      let(:oai_params) {{ verb: 'ListIdentifiers' }}
      let(:new_params) {{ verb: 'ListIdentifiers', resumptionToken: token }}
      let(:key) { 'identifier' }
      let(:value) { doc.css(key).to_ary.map(&:text).size }
      let(:token) { doc.css('resumptionToken').text }

      it 'returns 200 with the first page of identifiers and a token to paginate to next page' do
        get :index, oai_params
        expect(response).to be_successful
        expect(value).to eq(1)
        expect(token).to be_a(String)
        get :index, new_params
        expect(response).to be_successful
      end
    end

    context 'for verb ListRecords' do
      context 'without required parameters' do
        let(:oai_params) {{ verb: 'ListRecords' }}
        let(:key) { 'error' }
        let(:attribute) { 'code' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with bad argument error' do
          get :index, oai_params
          expect(response).to be_successful
          expect(value).to eq('badArgument')
        end
      end

      context 'with required parameters' do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc' }}
        let(:key) { 'identifier' }

        it 'returns 200 with the first page of results and paginates via tokens' do
          # get first page and token to second page
          get :index, oai_params
          expect(response).to be_successful
          doc = Nokogiri::XML.parse(response.body)
          token = doc.css('resumptionToken').text
          value = doc.css(key).to_ary.map(&:text).size
          expect(value).to eq(1)
          expect(token).to be_a(String)
          expect(token.split(':').last).to eq('2')

          # get second page and token to third page
          get :index, { verb: 'ListRecords', resumptionToken: token }
          expect(response).to be_successful
          doc = Nokogiri::XML.parse(response.body)
          token = doc.css('resumptionToken').text
          expect(token.split(':').last).to eq('3')

          # get final (third) page
          get :index, { verb: 'ListRecords', resumptionToken: token }
          expect(response).to be_successful
          doc = Nokogiri::XML.parse(response.body)
          # final page does not have a token
          expect(doc.css('resumptionToken')).to be_empty
        end
      end

      context 'with set filtering by collection', with_relationship_indexing: true do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc', set: "collection:#{collection.id}" }}
        let(:key) { 'identifier' }
        let(:value) { doc.css(key).to_ary.map(&:text).size }
        let(:token) { doc.css('resumptionToken').text }

        before do
          collection
          2.times do |j|
            article = FactoryGirl.create(:public_article)
            collection.library_collection_members << article
          end
        end

        it 'returns 200 with the first page of results and a token to next page' do
          get :index, oai_params
          expect(value).to eq(1)
          expect(token).to be_a(String)
        end
      end

      context 'with set filtering by model' do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc', set: 'model:Article' }}
        let(:key) { 'identifier' }
        let(:value) { doc.css(key).to_ary.map(&:text).size }
        let(:token) { doc.css('resumptionToken').text }

        it 'returns 200 with the first page of results and a token to next page' do
          get :index, oai_params
          expect(value).to eq(1)
          expect(token).to be_a(String)
        end
      end

      context 'with date filtering for only past records' do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc', until: Time.now-2.days }}
        let(:key) { 'error' }
        let(:attribute) { 'code' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 but all results are filtered out' do
          get :index, oai_params
          expect(value).to eq('noRecordsMatch')
        end
      end

      context 'with date filtering for current records' do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc', from: Time.now-1.days, until: Time.now+1.days }}
        let(:key) { 'identifier' }
        let(:value) { doc.css(key).to_ary.map(&:text).size }
        let(:token) { doc.css('resumptionToken').text }

        it 'returns 200 and first page of results' do
          get :index, oai_params
          expect(value).to eq(1)
          expect(token).to be_a(String)
        end
      end

      context 'with invalid model set filter value' do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc', set: 'model:FakeModel' }}
        let(:key) { 'error' }
        let(:attribute) { 'code' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with the first page of results and a token to next page' do
          get :index, oai_params
          expect(value).to eq('badArgument')
        end
      end

      context 'with invalid collection set filter value' do
        let(:oai_params) {{ verb: 'ListRecords', metadataPrefix: 'oai_dc', set: "collection:not_a_record" }}
        let(:key) { 'error' }
        let(:attribute) { 'code' }
        let(:value) { doc.css(key).attr(attribute).value }

        it 'returns 200 with the first page of results and a token to next page' do
          get :index, oai_params
          expect(value).to eq('noRecordsMatch')
        end
      end
    end

    context 'for verb ListMetadataFormats' do
      let(:oai_params) {{ verb: 'ListMetadataFormats' }}
      let(:key) { 'metadataPrefix' }
      let(:value) { doc.css('metadataPrefix').text }
      let(:dc_format) { 'oai_dc' }
      let(:dcterms_format) { 'dcterms' }

      it 'returns 200 and includes all registered metadata formats' do
        get :index, oai_params
        expect(response).to be_successful
        expect(value).to eq(dc_format + dcterms_format)
      end
    end
  end
end
