require 'spec_helper'

describe ReindexWorker do
  let(:id_list) { ["pid:1", "pid:2", "pid:3", "pid:4"] }

  it 'defaults to indexing everything' do
    worker = ReindexWorker.new
    expect(worker.pids_to_reindex).to eq(:everything)
  end

  it 'reindexes everything' do
    worker = ReindexWorker.new
    expect(worker).to receive("reindex_everything")
    worker.run
  end

  it 'reindexes selected ids' do
    worker = ReindexWorker.new(id_list)
    n = id_list.length
    object = double('ActiveFedora::Base')
    expect(object).to receive("update_index").exactly(n).times
    expect(ActiveFedora::Base).to receive("find").and_return(object).exactly(n).times
    expect(Curate.relationship_reindexer).to receive(:call).exactly(n).times
    worker.run
  end
end
