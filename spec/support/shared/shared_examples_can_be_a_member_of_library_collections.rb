shared_examples 'can_be_a_member_of_library_collections' do
  CurationConcern::FactoryHelpers.load_factories_for(self, described_class)

  context '#library_collections relationship' do
    subject { described_class.new.reflections.fetch(:library_collections).macro }
    it { is_expected.to eq(:has_and_belongs_to_many) }
  end
end
