require 'spec_helper'

describe Api::UploadsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }

  describe '#trx_initiate' do
    context 'with api token which grants access' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response).to be_successful
      end
    end

    context 'without api token which grants access' do
      it 'returns 417 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response.status).to eq(417) #expectation_failed
      end
    end
  end
end
