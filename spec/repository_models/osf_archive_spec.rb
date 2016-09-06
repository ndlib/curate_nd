require 'spec_helper'

describe OsfArchive do
  subject { OsfArchive.new }

  it { should have_unique_field(:title) }
  it { should have_unique_field(:source) }
  it { should have_unique_field(:type) }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'with_access_rights'
  it_behaves_like 'can_be_a_member_of_library_collections'
  it_behaves_like 'is_embargoable'

  describe 'new archive' do
    let(:archive) {OsfArchive.new}

    it 'type is stamped OSF Archive' do
      expect(archive.type).to eq('OSF Archive')
    end

    it "should set initialize dates on create" do
      archive.valid?
      expect(archive.date_modified).to eq(Date.today)
      expect(Date.parse(archive.date_archived)).to eq(Date.today)
    end
  end
end
