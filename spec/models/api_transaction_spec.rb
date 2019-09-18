require 'spec_helper'

describe ApiTransaction do
  subject { described_class }
  let(:tid) { '13131313' }
  let(:new_trx) do
    ApiTransaction.new(
      trx_id: '13131313',
      user_id: 1,
      work_id: '11111',
      trx_status: 'test'
    )
  end

  it { is_expected.to respond_to(:new_trx_id) }
  it { is_expected.to respond_to(:status_for) }
  it { is_expected.to respond_to(:set_status_based_on) }

  before do
    new_trx.save
  end

  describe '#set_status_based_on' do
    let(:update_trx_status) { subject.set_status_based_on(trx_id: tid, action: action) }

    describe 'with a valid action' do
      let(:action) { :commit }

      it 'updates the ApiTransaction record and returns true' do
        expect(update_trx_status).to eq true
        expect(ApiTransaction.find(tid).trx_status).to eq('submitted_for_ingest')
      end
    end

    describe 'with an invalid action' do
      let(:action) { :invalid }

      it 'does not update ApiTransaction and returns false' do
        expect(update_trx_status).to eq false
        expect(ApiTransaction.find(tid).trx_status).to eq('test')
      end
    end
  end
end
