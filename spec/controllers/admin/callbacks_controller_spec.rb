require 'spec_helper'

describe Admin::CallbacksController do
  let(:user) { FactoryGirl.create(:user) }
  let(:tid) { '12345'}
  let(:work_id) { '45678'}
  let(:trx) { ApiTransaction.new(trx_id: tid, user_id: user.id, trx_status: "test", work_id: work_id) }
  let(:something) { double }
  let(:read_body) { "{ \"host\" : \"libvirt8.library.nd.edu\", \"version\" : \"1.0.1\", \"job_name\" : \"ingest-45\", \"job_state\" : \"success\" }" }

  describe '#callback_response' do
    let(:response_data) { 'ingest_completed' }

    before do
      trx.save
      allow(controller).to receive(:validated).and_return(valid_response)
      # mocking the json body because i was unable to send both the params and the body in the post
      allow(request).to receive(:body).and_return(something)
      allow(something).to receive(:read).and_return(read_body)
    end

    describe 'when response is authorized via basic_auth' do
      let(:valid_response) { true }

      it 'processes the callback' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :callback_response, { tid: tid, response: response_data }
        expect(response).to be_successful
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id", "ingest_response")
        expect(ApiTransaction.find(tid).trx_status).to eq('ingest_complete')
      end
    end

    describe 'when response is unauthorized via basic_auth' do
      let(:valid_response) { false }

      it 'processes the callback' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :callback_response, { tid: tid, response: response_data }
        expect(response.status).to eq(401) # unauthorized
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id", "callback_response")
        expect(ApiTransaction.find(tid).trx_status).to eq('test')
      end
    end

    describe 'when callback status cannot update database table' do
      let(:valid_response) { true }
      let(:read_body) { "{ \"host\" : \"libvirt8.library.nd.edu\", \"version\" : \"1.0.1\", \"job_name\" : \"ingest-45\", \"job_state\" : \"invalid\" }" }

      it 'processes the callback' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :callback_response, { tid: tid, response: response_data }
        expect(response.status).to eq(304) # :not_modified
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id", "ingest_response", "callback_response")
        expect(ApiTransaction.find(tid).trx_status).to eq('test')
      end
    end
  end
end
