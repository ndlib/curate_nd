require 'spec_helper'

describe Api::UploadsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }
  let(:transaction) { ApiTransaction.new(trx_id: '12345', user_id: user.id, trx_status: "test") }
  let(:failed_trx) { double(ApiTransaction) }

  describe '#trx_initiate' do
    context 'with api token which grants access' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response).to be_successful
        expect(response.body).to include("trx_id")
      end
    end

    context 'when save fails' do
      before do
        allow(ApiTransaction).to receive(:new).and_return(failed_trx)
        allow(failed_trx).to receive(:save).and_return false
      end

      it 'returns 417 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response.status).to eq(417)
        expect(response.body).to include("Transaction not initiated")
      end
    end

    context 'without api token which grants access' do
      it 'returns 401 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response.status).to eq(401) #expectation_failed
        expect(response.body).to include("Token is required to authenticate user")
      end
    end
  end

  describe '#trx_new_file' do
  end

  describe '#trx_new_file' do
  end

  describe '#trx_append' do
  end

  describe '#trx_commit' do
  end

  describe '#trx_status' do
    let(:trx) { transaction }

    context 'with a valid transaction id' do
      before do
        trx.save
      end

      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_status, { tid: trx.trx_id }
        expect(response).to be_successful
        expect(response.body).to eq "{\"trx_id\":\"12345\",\"status\":\"test\"}"
      end
    end

    context 'with an invalid transaction id' do
      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_status, { tid: 'bbbbb' }
        expect(response).to be_not_found
        expect(response.body).to include("Transaction not found")
      end
    end
  end
end
