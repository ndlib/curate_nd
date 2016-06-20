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

    context '.find_preservation_document_by' do
      context 'for a library collectable item' do
        it 'will return a Curate::Indexer::Documents::PreservationDocument' do
          work = FactoryGirl.create(:document)
          expect(described_class.find_preservation_document_by(work.pid)).to be_a(Curate::Indexer::Documents::PreservationDocument)
        end
      end
      context 'for a non-library collectable item' do
        it 'will return a Curate::Indexer::Documents::PreservationDocument with empty parent_pids' do
          work = double('Work', pid: '123')
          allow(ActiveFedora::Base).to receive(:find).and_return(work)
          preservation_document = described_class.find_preservation_document_by(work.pid)
          expect(preservation_document.parent_pids).to eq([])
        end
      end
    end

    context '.each_preservation_document' do
      it 'will iterate through Fedora and yield Curate::Indexer::Documents::PreservationDocument instances' do
        work = FactoryGirl.create(:document)
        expect { |b| described_class.each_preservation_document(&b) }.to yield_with_args(Curate::Indexer::Documents::PreservationDocument)
      end
    end
  end
end
