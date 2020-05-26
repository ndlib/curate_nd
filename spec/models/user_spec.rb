require 'spec_helper'

describe User do

  context '.search' do
    subject { described_class }
    its(:search) { should be_kind_of ActiveRecord::Relation }
    it 'should create a valid query' do
      User.search('h').count
    end
  end

  it 'should set agree to terms of service' do
    allow_any_instance_of(User).to receive(:get_value_from_ldap).and_return(nil)
    user = FactoryGirl.create(:user, agreed_to_terms_of_service: false)
    expect(user.agreed_to_terms_of_service?).to eq false
    user.agree_to_terms_of_service!
    expect(user.agreed_to_terms_of_service?).to eq true
  end

  it 'has a #to_s that is #username' do
    expect(User.new(username: 'hello').to_s).to eq 'hello'
  end

  describe '#update_with_password' do
    let(:user) { FactoryGirl.create(:user) }
    let(:email) { 'hello@world.com' }
    it 'should update email, if given' do
      allow_any_instance_of(User).to receive(:get_value_from_ldap).and_return(nil)
      expect {
        user.update_with_password(email: email)
      }.to change(user, :email).from('').to(email)
    end
  end

  describe '.batchuser' do
    it 'persists an instance the first time, then returns the persisted object' do
      allow_any_instance_of(User).to receive(:get_value_from_ldap).and_return(nil)
      expect {
        User.batchuser
      }.to change { User.count }.by(1)

      expect {
        User.batchuser
      }.to change { User.count }.by(0)
    end
  end

  describe '.audituser' do
    it 'persists an instance the first time, then returns the persisted object' do
      allow_any_instance_of(User).to receive(:get_value_from_ldap).and_return(nil)
      expect {
        User.audituser
      }.to change { User.count }.by(1)

      expect {
        User.audituser
      }.to change { User.count }.by(0)
    end
  end

  let(:user){
    @user = User.new
    @user.username = "jsmith.test"
    @user
  }

  let(:new_user){
    @new_user = User.new
    @new_user.username = "test_user"
    @new_user.email= "test.user@example.com"
    @new_user
  }

  let(:another_user){
    @another_user = User.new
    @another_user.username = "test_user"
    @another_user
  }

end
