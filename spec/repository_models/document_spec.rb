require 'spec_helper'

describe Document do
  subject {  FactoryGirl.build(:document) }

  it { should have_unique_field(:title) }
  it { should have_unique_field(:type) }

  it_behaves_like 'is_a_curation_concern_model'
  it_behaves_like 'can_be_a_member_of_library_collections'
  it_behaves_like 'with_related_works'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_dc_metadata'
  it_behaves_like 'has_common_solr_fields'

  describe 'valid types: ' do
    let(:doc) { FactoryGirl.build(:document) }

    Document.valid_types.each do |type|
      it "type '#{type}' is valid" do
        doc.type = type
        doc.valid?
        expect(doc.errors[:type]).to_not be_present
      end
    end

    it 'non-whitelist types are not valid' do
      doc.type = 'Invalid document type'
      doc.valid?
      expect(doc.errors[:type]).to be_present
    end

    it 'type can be nil' do
      doc.type = nil
      expect(doc.errors[:type]).to_not be_present
    end
  end

  describe 'human_readable_type' do
    let(:doc) { FactoryGirl.build(:document) }
    it 'should have document as human_readable_type when type id nil ' do
      doc.type = nil
      expect(doc.human_readable_type).to eq('Document')
    end

    it 'should have type value as human_readable_type when type not nil ' do
      doc.type = 'my_new_type'
      expect(doc.human_readable_type).to eq('My New Type')
    end
  end

end

describe Document do
  subject { Document.new }

  it_behaves_like 'with_access_rights'

end
