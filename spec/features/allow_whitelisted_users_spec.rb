require 'spec_helper'

describe 'Whitelisted users: ' do
  let(:user) { FactoryGirl.create(:user) }
  let!(:work1) { FactoryGirl.create(:generic_work, user: user, title: 'Work 1') }
  let!(:work2) { FactoryGirl.create(:generic_work, user: user, title: 'Work 2') }
  let!(:collection) { FactoryGirl.create(:public_collection, user: user, title: 'Collected Stuff') }

  describe "As a whitelisted user, I " do
    before do
      login_as(user)
    end
    it 'should see options to create work' do
      visit '/'
      page.should have_content("New Article")
      page.should have_content("Log Out")
      page.should have_link("Add to Collection")
    end
  end

  describe "As a non-whitelisted user, I " do
    before do
      user.stub(:whitelisted?).and_return(false)
      login_as(user)
    end
    it 'should not see options to create work' do
      visit '/'
      page.should_not have_content("New Article")
      page.should have_content("Log Out")
      page.should_not have_link("Add to Collection")
    end
  end
end
