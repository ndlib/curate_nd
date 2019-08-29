require 'spec_helper'

describe Api::StorageForIngest do
 describe '#put' do
    let(:bucket) { Api::StorageForIngest.new }
    let(:path) { "abcdefg/WEBHOOK" }
    let(:body) { 'https://uploads/abcdefg/callback/ingest_completed.json' }
    let(:storage_object) { bucket.put(named_path: path, body: body) }

    it 'writes body to path' do
      expect(storage_object).to eq(body)
    end
  end
end
