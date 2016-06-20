require 'spec_helper'
require 'curate/indexing_adapter'
require 'curate/indexer/adapters/abstract_adapter'

module Curate
  RSpec.describe IndexingAdapter do
    it 'is the adapter for the Curate::Indexer', context: :integration do
      expect(Curate::Indexer.adapter).to eq(described_class)
    end
    it 'implements all of the methods of the Curate::Indexer::Adapters::AbstractAdapter' do
      methods_implemented_in_abstract = Curate::Indexer::Adapters::AbstractAdapter.methods(false)
      methods_implemented_for_curate_nd_indexing = described_class.methods(false)

      # Looking at the intersection of methods defined in each of the modules
      # If the intersection is the same as the methods in the abstract, then we have adequately implemented the interface
      expect((methods_implemented_for_curate_nd_indexing & methods_implemented_in_abstract).sort).to eq(methods_implemented_in_abstract.sort)
    end
  end
end
