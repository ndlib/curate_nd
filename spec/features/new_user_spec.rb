require 'spec_helper_features'

describe 'first time user', FeatureSupport.options do
  let(:email) { 'hello@world.com' }
  let(:name) { "Hello World" }
  let(:new_name) { "Mrs. #{name}"}
  let(:user) {
    FactoryGirl.create(
      :user,
      agreed_to_terms_of_service: false,
      email: email,
      user_does_not_require_profile_update: false,
      sign_in_count: 0
    )
  }

  it 'prompts me to fill in my user profile the first time I log in' do
    visit('/')
    login_as(user) # Short circuiting CAS
    click_link "Get Started"
    click_button "I Agree"
    within('form.edit_user') do
      fill_in("user[name]", with: new_name)
      fill_in("user[preferred_email]", with: email)
      click_button("Update")
    end

    page.should have_content("Search CurateND")

    logout
    visit('/')
    login_as(user)
    click_link "Get Started"
    page.assert_selector("h2", text: "What are you uploading?")
  end
end
