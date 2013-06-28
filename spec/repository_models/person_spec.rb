require 'spec_helper'

describe Person do

  let(:user){
    @user = FactoryGirl.create(:user)
  }

  describe '.find_or_create_by_user' do
    it 'should create a new person object' do 
      User.any_instance.stub(:alternate_email) { "jsmith.test@example.com" }
      User.any_instance.stub(:display_name) { "John Smith" }
      obtained_result = Person.find_or_create_by_user(user)
      obtained_result.class.should eq Person
    end
  end
end
