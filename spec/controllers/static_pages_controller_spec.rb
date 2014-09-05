require 'spec_helper'

describe StaticPagesController do

  context 'GET #502.html' do
    it 'should respond with 502 status' do
      get 'timeout_error'
      expect(response.status).to eq(502)
      expect(assigns(:help_request)).to be_an_instance_of(HelpRequest)
    end
  end

end
