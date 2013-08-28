require 'spec_helper'

describe Person do

  let(:user){
    @user = User.new
    @user.username= "jsmith@example.com"
    @user.save
    @user.stub(:email).and_return("jsmith.test@example.com")
    @user.stub(:display_name).and_return("John Smith")
    @user
  }

end
