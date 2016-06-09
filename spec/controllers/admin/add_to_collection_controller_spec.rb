require 'spec_helper'
require 'json'

describe Admin::AddToCollectionController do
  it 'accepts a JSON hash' do
    data = {'pid:1' => ['pid:2', 'pid:3', 'pid:4'],
            'pid:5' => 'pid:6',
            '7' => '8'}
    reindexer = double
    expect(Sufia.queue).to receive(:push).exactly(3).times
    expect(CollectionAdderWorker).to receive(:new).with('pid:1', ['pid:2', 'pid:3', 'pid:4'])
    expect(CollectionAdderWorker).to receive(:new).with('pid:5', ['pid:6'])
    expect(CollectionAdderWorker).to receive(:new).with('und:7', ['und:8'])
    post :submit, data.to_json
    expect(response.status).to eq(200)
  end

  it 'returns a 400 on bad input' do
    data = "not json data"
    post :submit, data
    expect(response.status).to eq(400)
  end

  it 'returns a 400 on json arrays' do
    data = [ :an, "array" ]
    post :submit, data.to_json
    expect(response.status).to eq(400)
  end
end
