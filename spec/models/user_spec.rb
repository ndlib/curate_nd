require 'spec_helper'

describe User do

  it 'should set agree to terms of service' do
    User.any_instance.stub(:get_value_from_ldap).and_return(nil)
    user = FactoryGirl.create(:user, agreed_to_terms_of_service: false)
    user.agreed_to_terms_of_service?.should == false
    user.agree_to_terms_of_service!
    user.agreed_to_terms_of_service?.should == true
  end

  it 'has a #to_s that is #username' do
    User.new(username: 'hello').to_s.should == 'hello'
  end

  describe '#update_with_password' do
    let(:user) { FactoryGirl.create(:user) }
    let(:email) { 'hello@world.com' }
    it 'should update email, if given' do
      User.any_instance.stub(:get_value_from_ldap).and_return(nil)
      expect {
        user.update_with_password(email: email)
      }.to change(user, :email).from('').to(email)
    end
  end

  describe '.batchuser' do
    it 'persists an instance the first time, then returns the persisted object' do
      User.any_instance.stub(:get_value_from_ldap).and_return(nil)
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
      User.any_instance.stub(:get_value_from_ldap).and_return(nil)
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

  it 'should create an associated Person object' do
    User.any_instance.stub(:get_value_from_ldap).and_return(nil)
    user.repository_id.should == nil
    user.person.class.should == Person
    user.save!
    user.repository_id.should_not == nil
  end

  let(:new_user){
    @new_user = User.new
    @new_user.username = "test_user"
    @new_user.email= "test.user@example.com"
    @new_user
  }

  let(:another_user){
    @another_user = User.new
    @another_user.username = "test_user"
    @another_user.stub_chain(:ldap_service, :display_name).and_return(nil)
    @another_user
  }

  it 'should save the assoicated person object when user is saved' do
    User.any_instance.stub(:get_value_from_ldap).and_return(nil)
    another_user.save!
    another_user.person.name.should == nil

    another_user.name = "Test User"
    another_user.save!

    another_user.person.name.should == "Test User"
  end
end
