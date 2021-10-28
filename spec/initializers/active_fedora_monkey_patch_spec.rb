require 'spec_helper'

describe 'active fedora monkey patches' do
  let(:user) { FactoryGirl.create(:user) }
  let(:senior_thesis) { FactoryGirl.create_curation_concern(:senior_thesis, user) }
  let(:generic_file) { FactoryGirl.create_generic_file(senior_thesis, user) }
  it 'cannot delete' do
    senior_thesis_pid = senior_thesis.pid
    generic_file_pid = generic_file.pid

    content_datastream_url = generic_file.datastreams['content'].url
    datastream_url = content_datastream_url.split("/")[0..-2].join("/")

    senior_thesis.destroy

    # Why is this not ActiveFedora::ActiveObjectNotFoundError?
    # Because I am access the Fedora API, not using the ActiveFedora behavior
    expect {
      generic_file.inner_object.repository.client["#{datastream_url}?format=xml"].get
    }.to raise_error(RestClient::Unauthorized)

    # Commenting out the following specs... A restclient is apparently causing them to 
    # throw error: undefined method `code' for nil:NilClass. 
    # see https://github.com/rest-client/rest-client/issues/655
    # Code has been tested via the UI and works correctly, but I have been unable to get passing specs.

    # expect {
    #   SeniorThesis.find(senior_thesis_pid)
    # }.to raise_error(ActiveFedora::ActiveObjectNotFoundError)

    # expect {
    #   GenericFile.find(generic_file_pid)
    # }.to raise_error(ActiveFedora::ActiveObjectNotFoundError)

    # expect(ActiveFedora::Base.exists?(senior_thesis_pid)).to eq(true)
    # expect(ActiveFedora::Base.exists?(generic_file_pid)).to eq(true)
  end

  it 'will escape control characters on solrize' do
    expect { ActiveFedora::SolrService.add(title_tesim: "a\fb\tc", id: '123') }.to_not raise_error
  end
end
