require 'spec_helper'

describe Api::ItemsController do
  let(:work) { FactoryGirl.create(:generic_work) }
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }

  describe '#show' do
    context 'with api token which grants access' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work.to_param }
        expect(response).to be_successful
      end
    end

    context 'with api token which does not grant access' do
      it 'returns 403 and json document' do
        request.headers['X-Api-Token'] = 'abc'
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work.to_param }
        expect(response).to be_forbidden
      end
    end

    context 'without api token' do
      it 'returns 403 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :show, { id: work.to_param }
        expect(response).to be_forbidden
      end
    end
  end
end
