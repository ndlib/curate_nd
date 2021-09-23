require 'spec_helper'

describe OrphanFileRequest do
  let(:user) { FactoryGirl.create(:user) }
  let(:request_factory) { FactoryGirl.create(:orphan_file_request, file_id: '12345', work_id: '67890', user_id: user.id, user_email: "user@example.com") }
  let(:bad_factory) { FactoryGirl.create(:orphan_file_request) }

  
  context 'test support' do
    it 'has a valid factory' do
      expect(request_factory).to be_valid
    end
  end

  context 'when being created' do
    it 'requires information' do
      expect{ bad_factory }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#mark_completed' do
    let(:subject) { request_factory }
  
    it 'should accept a "completed date" and updating_user' do
      subject.mark_completed_by(user)
      expect(subject.completed_date).to_not be_nil
      expect(subject.updating_user_id).to_not be_nil
    end
  end
end