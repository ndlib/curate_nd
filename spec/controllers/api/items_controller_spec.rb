require 'spec_helper'

describe Api::ItemsController do
  let(:public_article) { FactoryGirl.create(:public_article, title: 'Fried Green Tomatoes',) }
  let(:private_article) { FactoryGirl.create(:article, title: 'All About Cats', user: user) }
  let(:private_work) { FactoryGirl.create(:private_generic_work, title: 'More About Cats', user: user) }
  let(:generic_work_with_files) { FactoryGirl.create(:generic_work_with_files, title: 'I have 3 files', user: user) }
  let(:generic_file) { FactoryGirl.create(:generic_file, user: user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }

  describe '#show' do
    context 'with api token which grants access' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: private_work.to_param }
        expect(response).to be_successful
      end
    end

    context 'with invalid api token' do
      it 'returns 403 and json document for private work' do
        request.headers['X-Api-Token'] = 'abc'
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: private_work.to_param }
        expect(response).to be_forbidden
      end

      it 'returns 200 and json document for public work' do
        request.headers['X-Api-Token'] = 'abc'
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: public_article.to_param }
        expect(response).to be_successful
      end
    end

    context 'without api token' do
      it 'returns 403 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: private_work.to_param }
        expect(response).to be_forbidden
      end

      it 'returns 200 and json document for public work' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: public_article.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe '#index' do
    before do
      public_article
      private_article
      private_work
    end

    context 'with no search parameters' do
      it 'includes all authorized works, and returns status 200 with first page of results in expected json format' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :index
        expect(response).to be_successful
        json = JSON.parse(response.body)

        expect(json['pagination']['totalResults']).to eq(3)
        expect(json.keys).to eq(["query", "results", "pagination"])
        expect(json['query'].keys).to eq(["queryUrl", "queryParameters"])
        expect(json['results']).to be_a Array
        expect(json['results'].first.keys).to include("id", "title", "type", "itemUrl")
        expect(json['pagination'].keys).to include("itemsPerPage", "totalResults", "currentPage", "firstPage", "lastPage")
      end
    end

    context 'with valid search parameters' do
      it 'recognizes searches for valid search terms, filters returned data, and includes terms in results' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :index, { type: 'Article', editor: "self", depositor: "self" }
        expect(response).to be_successful
        json = JSON.parse(response.body)

        expect(json['pagination']['totalResults']).to eq(1)
        expect(json['results'].first.keys).to include("type", "editor", "depositor")
        expect(json['query']['queryParameters'].keys).to include("type", "editor", "depositor")
      end
    end

    context 'with date filtering' do
      let(:requested_date) { "after:2019-01-01" }

      it 'searches dates and includes dates in the search results list' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :index, { deposit_date: requested_date, modify_date: requested_date }
        expect(response).to be_successful
        json = JSON.parse(response.body)

        expect(json['pagination']['totalResults']).to eq(3)
        expect(json['results'].first.keys).to include("depositDate", "modifyDate")
        expect(json['query']['queryParameters'].keys).to include("deposit_date", "modify_date")
      end
    end
  end

  describe '#download' do
    context 'with authority to item' do
      context 'when item is a work with several files' do
        it 'has X-Accel-Redirect header to download zip files in response' do
          request.headers['X-Api-Token'] = token.sha
          request.headers['HTTP_ACCEPT'] = "application/json"
          get :download, { id: generic_work_with_files.to_param }
          file_list = generic_work_with_files.generic_files.map{|file| Sufia::Noid.noidify(file.id) }
          expect(response.headers.fetch('X-Accel-Redirect')).to eq("/download-content/#{generic_work_with_files.to_param}/zip/#{file_list.join(',')}")
        end
      end

      context 'when item is a generic file' do
        it 'has X-Accel-Redirect header to single download in response' do
          request.headers['X-Api-Token'] = token.sha
          request.headers['HTTP_ACCEPT'] = "application/json"
          get :download, { id: generic_file.to_param }
          expect(response.headers.fetch('X-Accel-Redirect')).to eq("/download-content/#{generic_file.to_param}")
        end
      end
    end

    context 'without authority to item' do
      it 'returns 403 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :download, { id: generic_file.to_param }
        expect(response).to be_forbidden
      end
    end

    context 'with file not found' do
      it 'returns 404 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :download, { id: "abcdefg" }
        expect(response).to be_not_found
      end
    end
  end

  describe '#initiate_trx' do
    context 'with api token which grants access' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :initiate_trx
        expect(response).to be_successful
      end
    end

    context 'without api token which grants access' do
      it 'returns 417 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :initiate_trx
        expect(response.status).to eq(417) #expectation_failed
      end
    end
  end
end
