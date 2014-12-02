require 'spec_helper'

describe Repository do
  context '#build_new_senior_thesis_form' do
    subject { described_class.new.build_new_senior_thesis_form }
    it { should respond_to :model }
    it { should respond_to :attributes }
    it { should respond_to :submit }
  end

  context '#submit_new_senior_thesis_form' do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:form) { described_class.new.build_new_senior_thesis_form(attributes: attributes) }
    let(:file) { Rack::Test::UploadedFile.new(__FILE__, 'text/plain', false) }
    let(:attributes) do
      {
        date_created: '2014-12-14', title: 'Hello World', description: 'Lorem', creator: 'Jeremy Friesen',
        rights: "All rights reserved", visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        accept_contributor_agreement: '1', files: [file], doi_assignment_strategy: :mint_doi
      }
    end
    subject { described_class.new }
    context 'when valid' do
      it 'will create a new senior thesis' do
        expect(form).to be_valid
        response, messages = subject.submit_new_senior_thesis_form(form: form, current_user: current_user)
        expect(messages.first.message_id).to eq(:minting_doi)
        senior_thesis = response.class.find(response.pid)
        expect(senior_thesis.generic_files.size).to eq(1)
        generic_file = senior_thesis.generic_files.first
        expect(generic_file.original_checksum).to be_present
        expect(senior_thesis.visibility).to eq('open')
      end
    end
  end
end
