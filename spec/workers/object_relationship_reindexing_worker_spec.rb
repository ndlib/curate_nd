require 'spec_helper'
require 'object_relationship_reindexing_worker'

RSpec.describe ObjectRelationshipReindexerWorker do
  let(:pid) { 'UND:1234' }
  let(:worker) { described_class.new(pid) }
  context '#run' do
    it 'will call the Curate::Indexer.reindex_relationships' do
      expect(Curate::Indexer).to receive(:reindex_relationships).with(pid)
      worker.run
    end

    it 'will call Error Handler if an exception is encountered and re-raise the exception' do
      expect(Sentry).to receive(:capture_exception)
      allow(Curate::Indexer).to receive(:reindex_relationships).and_raise(RuntimeError)
      expect { worker.run }.to raise_error(RuntimeError)
    end
  end
end
