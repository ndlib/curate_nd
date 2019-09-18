require 'spec_helper'

describe Api::CallbackTrxValidator do
  let(:user) { FactoryGirl.create(:user) }
  let(:tid) { '12345'}
  let(:work_id) { '45678'}
  let(:trx) { ApiTransaction.new(trx_id: tid, user_id: user.id, trx_status: "test", work_id: work_id) }
  let(:user_hash) { Digest::MD5.hexdigest(user.username) }
  let(:trx_hash) { Digest::MD5.hexdigest(tid) }

  describe '#validate' do
    describe 'when authentication is missing' do
      it 'returns false' do
        expect(Api::CallbackTrxValidator.new(trx_id: nil , user_name_hash: user_hash, trx_id_hash: trx_hash).validate).to be false
        expect(Api::CallbackTrxValidator.new(trx_id: tid , user_name_hash: nil, trx_id_hash: trx_hash).validate).to be false
        expect(Api::CallbackTrxValidator.new(trx_id: tid , user_name_hash: user_hash, trx_id_hash: nil).validate).to be false
      end
    end

    describe 'when trx_id does not exist' do
      it 'returns false' do
        expect(Api::CallbackTrxValidator.new(trx_id: '55555', user_name_hash: user_hash, trx_id_hash: trx_hash).validate).to be false
      end
    end

    describe 'when authentication is validated' do
      before do
        trx.save
      end

      it 'returns true' do
        expect(Api::CallbackTrxValidator.new(trx_id: tid, user_name_hash: user_hash, trx_id_hash: trx_hash).validate).to be true
      end
    end
  end
end
