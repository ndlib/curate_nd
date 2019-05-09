require 'spec_helper'

describe Api::ItemsController do
  let(:work1) { FactoryGirl.create(:public_generic_work) }
  let(:work2) { FactoryGirl.create(:private_generic_work, user: user) }
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }

  describe '#show' do
    context 'with api token which grants access' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work2.to_param }
        expect(response).to be_successful
      end
    end

    context 'with invalid api token' do
      it 'returns 403 and json document for private work' do
        request.headers['X-Api-Token'] = 'abc'
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work2.to_param }
        expect(response).to be_forbidden
      end

      it 'returns 200 and json document for public work' do
        request.headers['X-Api-Token'] = 'abc'
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work1.to_param }
        expect(response).to be_successful
      end
    end

    context 'without api token' do
      it 'returns 403 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work2.to_param }
        expect(response).to be_forbidden
      end

      it 'returns 200 and json document for public work' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work1.to_param }
        expect(response).to be_successful
      end
    end
  end
end
