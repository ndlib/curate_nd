require 'spec_helper'

RSpec.describe LibraryCollection do
  let(:attributes) do
    {
      title: 'The Title', description: 'The Description', creator: ['The Creator', 'The Other Creator'],
      contributor: ['The Contributor', 'The Other Contributor'], based_near: ['The Nearby', 'The Other Nearby'],
      part_of: ['The Part of', 'The Other Part of'], publisher: ['The Publisher', 'The Other Publisher'],
      date_created: ['2016-06-10', '2016-06-09'], subject: ['The Subject', 'The Other Subject'], resource_type: ["RT1", 'RT2'],
      rights: ["Rights1", 'Rights2'], identifier: ["ID1", "ID2"], language: ["Lang1", 'Lang2'], tag: ["Tag1", 'Tag2'],
      related_url: ['URL1', 'URL2'], administrative_unit: ["AU1", "AU2"], source: ['Source1', 'Source2'],
      curator: ['Curator1', 'Curator2'], date: ['Date1', 'Date2']
    }
  end
  context '.human_readable_type' do
    subject { described_class.human_readable_type }
    it { is_expected.to eq('Collection') }
  end
  context '#library_collection_members relationship' do
    subject { described_class.new.reflections.fetch(:library_collection_members).macro }
    it { is_expected.to eq(:has_many) }
  end
  context '#library_collections relationship' do
    subject { described_class.new.reflections.fetch(:library_collections).macro }
    it { is_expected.to eq(:has_and_belongs_to_many) }
  end
  context 'create and update cycle' do
    it 'sets the metadata attributes, sets date uploaded, and launches and index job' do
      # Consolidating all of these expectations as the underlying tests
      # are very slow as they hit Fedora
      collection_pid = LibraryCollection.create!(attributes).pid
      # I want to reload and test the object
      collection = ActiveFedora::Base.find(collection_pid, cast: true)
      original_date_modified = collection.date_modified
      original_date_uploaded = collection.date_uploaded
      expect(original_date_uploaded).to be_present
      expect(original_date_modified).to be_present
      expect(collection.visibility).to eq(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
      attributes.each do |attribute_name, value|
        expect(collection.public_send(attribute_name)).to eq(value)
      end
      # Making sure we are not obliterating the date uploaded but are updating the date modified
      expect(collection).to receive(:set_date_modified)
      expect(collection).to_not receive(:set_date_uploaded)
      collection.update(attributes)
    end
  end
end
