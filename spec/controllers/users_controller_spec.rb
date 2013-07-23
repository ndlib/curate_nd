require 'spec_helper'

describe UsersController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'PUT update' do

    it "raise not_found if the object does not exist" do
      expect {
        put :update, id: '8675309'
      }.to raise_rescue_response_type(:not_found)
    end

    it 'should find and update user' do
      expect {
        put :update, { :id => user.id, :user => { :name => "John Smith" } }
      }.to change{user.reload.name}.from(user.name).to("John Smith")

      response.should redirect_to(dashboard_index_path)
    end

  end
end
