require 'spec_helper'

describe Person do

  let(:user){
    @user = User.new
    @user.username= "jsmith@example.com"
    @user.save
    @user.stub!(:email).and_return("jsmith.test@example.com")
    @user.stub!(:display_name).and_return("John Smith")
    @user
  }

  describe '.find_or_create_by_user' do
    it 'should create a new person object' do 
      obtained_result = Person.find_or_create_by_user(user)
      obtained_result.class.should eq Person
    end
  end
end
