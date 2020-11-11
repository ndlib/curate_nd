require 'spec_helper'

describe 'shared/simple_form_input_test.html.erb' do
  let(:object) { SeniorThesis.new }
  let(:user) { User.new }
  before(:each) do
    allow(controller).to receive(:current_user).and_return(user)
    assign(:object, object)
    render partial: 'simple_form_input_test'
  end
  it 'should have Cancel link which takes to root page' do
    expect(rendered).to have_tag('.form-group.senior_thesis_title') do
      with_tag('.control-label') do
        with_tag('label[for="senior_thesis_title"]') do
          with_tag('#senior_thesis_title_label', text: 'Title')
        end
        with_tag('.field-hint#senior_thesis_title_hint[role="tooltip"]')
      end
      with_tag('.controls') do
        with_tag('input[aria-required="true"][name="senior_thesis[title]"][aria-labelledby="senior_thesis_title_label"][aria-describedby="senior_thesis_title_hint"]')
      end
    end
  end
end
