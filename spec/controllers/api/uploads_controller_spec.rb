require 'spec_helper'

describe Api::UploadsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:token) { ApiAccessToken.create(issued_by: user.id, user: user) }
  let(:tid) { '12345'}
  let(:work_id) { '45678'}
  let(:trx) { ApiTransaction.new(trx_id: tid, user_id: user.id, trx_status: "test", work_id: work_id) }
  let(:failed_trx) { double(ApiTransaction) }
  let(:attached_file) { double }

  describe '#trx_initiate' do
    context 'with api token which grants access' do
      it 'returns 200 and json document and updates work_id' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response).to be_successful
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id", "work_id")
      end
    end

    context 'when metadata fails validation' do
      let(:formatter) { double }

      before do
        allow(Api::WorkMetadataFormatter).to receive(:new).and_return(formatter)
        allow(formatter).to receive(:valid?).and_return(false)
      end

      it 'returns 406 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response.status).to eq(406) # not_acceptable
        expect(response.body).to include('Invalid metadata for work')
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
        expect(response.status).to eq(417) # expectation_failed
        expect(response.body).to include("Transaction not initiated")
      end
    end

    context 'without api token which grants access' do
      it 'returns 401 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_initiate
        expect(response.status).to eq(401) # unauthorized
        expect(response.body).to include("Token is required to authenticate user")
      end
    end
  end

  describe '#trx_new_file' do
    context 'with api token which grants access' do
      let(:query_parameters) { { file_name: 'abcde.jpg' } }

      before do
        trx.save
        allow(request).to receive(:query_parameters).and_return(query_parameters)
      end

      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_new_file, tid: tid
        expect(response.status).to eq(200) # ok
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id", "file_name", "file_id", "sequence")
      end
    end

    context 'without file_name in query_parameters' do
      before do
        trx.save
      end

      it 'returns 406 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_new_file, tid: tid
        expect(response.status).to eq(406) # not_acceptable
        expect(response.body).to include('Invalid metadata for file')
      end
    end

    context 'without api token which grants access' do
      it 'returns 401 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_new_file, tid: tid
        expect(response.status).to eq(401) # unauthorized
        expect(response.body).to include("Token is required to authenticate user")
      end
    end
  end

  describe '#trx_append' do
    let(:fid) { "abcde" }

    context 'with api token which grants access' do
      before do
        trx.save
        allow(request).to receive(:body).and_return(attached_file)
      end

      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_append, tid: tid, fid: fid
        expect(response.status).to eq(200) # ok
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id", "file_id", "sequence")
      end
    end

    context 'without api token which grants access' do
      it 'returns 401 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_append,  tid: tid, fid: fid
        expect(response.status).to eq(401) # unauthorized
        expect(response.body).to include("Token is required to authenticate user")
      end
    end
  end

  describe '#trx_commit' do
    context 'with api token which grants access' do
      before do
        trx.save
        allow(controller).to receive(:callback_url).and_return('some/url')
      end

      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_commit, tid: tid
        expect(response.status).to eq(200) # ok
        expect(JSON.parse(response.body).keys).to contain_exactly("trx_id")
        expect(ApiTransaction.find(tid).trx_status).to eq('submitted_for_ingest')
      end
    end

    context 'without api token which grants access' do
      it 'returns 401 and json document' do
        request.headers['HTTP_ACCEPT'] = "application/json"
        post :trx_commit,  tid: tid
        expect(response.status).to eq(401) # unauthorized
        expect(response.body).to include("Token is required to authenticate user")
      end
    end
  end

  describe '#trx_status' do
    context 'with a valid transaction id' do
      before do
        trx.save
      end

      it 'returns 200 and json document' do
        request.headers['X-Api-Token'] = token.sha
        request.headers['HTTP_ACCEPT'] = "application/json"
        get :trx_status, { tid: trx.trx_id }
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq( {"trx_id"=>"12345", "status"=>"test"} )
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
