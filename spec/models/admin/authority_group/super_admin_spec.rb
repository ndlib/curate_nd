require 'spec_helper'

describe Admin::AuthorityGroup::SuperAdmin do
  it_behaves_like 'is_an_authority_group_class', described_class, :super_admin_grp

  context 'behavior' do
    let(:user1) { FactoryGirl.create(:user) }
    let(:user2) { FactoryGirl.create(:user) }
    let!(:super_admin) { FactoryGirl.create(:super_admin_grp, authorized_usernames: user1.username) }

    it 'grants authority to manage authority groups' do
      expect(user1.can?(:manage, Admin::AuthorityGroup)).to be_truthy
    end

    it 'restricts authority to manage authority groups' do
      expect(user2.can?(:manage, Admin::AuthorityGroup)).to be_falsey
    end

    it 'is also an admin' do
      expect(CurateND::AdminConstraint.is_admin?(user1)).to be_truthy
    end

    it 'gives additional authority' do
      expect(user1.can?(:orphan, GenericFile)).to be_truthy
      expect(user1.can?(:manage, ApiAccessToken)).to be_truthy
      expect(user2.can?(:orphan, GenericFile)).to be_falsey
      expect(user2.can?(:manage, ApiAccessToken)).to be_falsey
    end
  end
end
