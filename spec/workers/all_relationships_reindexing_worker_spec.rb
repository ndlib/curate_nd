require 'spec_helper'
require 'all_relationships_reindexing_worker.rb'

RSpec.describe AllRelationshipsReindexerWorker do
  let(:worker) { described_class.new }
  context '#run' do
    it 'will call the Curate::Indexer.reindex_all!' do
      expect(Curate::Indexer).to receive(:reindex_all!)
      worker.run
    end

    it 'will call Error Handler if an exception is encountered and re-raise the exception' do
      expect(Sentry).to receive(:capture_exception)
      expect(Curate::Indexer).to receive(:reindex_all!).and_raise(RuntimeError)
      expect { worker.run }.to raise_error(RuntimeError)
    end
  end
end
