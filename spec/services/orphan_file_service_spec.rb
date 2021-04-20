require 'spec_helper'

describe OrphanFileService do
  let(:subject) { OrphanFileService.orphan_file(file_id: my_file.pid, requested_by: some_user) }
  let(:authorized_user) { FactoryGirl.create(:user) }
  let(:my_article) { FactoryGirl.create_curation_concern(:article, user2) }
  let(:my_file) { FactoryGirl.create_generic_file(my_article, user2) }
  let(:user2) { FactoryGirl.create(:user) }
  let!(:super_admin) { FactoryGirl.create(:super_admin_grp, authorized_usernames: authorized_user.username) }

  before do
    my_file
    super_admin
  end

  context 'with ability to orphan a file' do
    let(:some_user) { authorized_user }
    it 'orphans the file and returns true' do
      expect(subject).to eq true
      expect(GenericFile.find(my_file.pid).parent).to be nil
    end
  end

  context 'when file is not found' do
    let(:some_user) { authorized_user }
    before do
      allow(GenericFile).to receive(:find).and_return(nil)
    end
    it 'returns false' do
      expect(subject).to eq false
    end
  end

  context 'without ability to orphan a file' do
    let(:some_user) { user2 }
    it 'returns false and does not remove parent' do
      expect(subject).to eq false
      expect(GenericFile.find(my_file.pid).parent).to eq(my_article)
    end
  end
end
