require 'spec_helper'

describe FileContentDatastream do
  let(:datastream) { FileContentDatastream }
  let(:dataStringIo) { "Datastream file stream content StrgIo" }

  describe '#determine_filesource' do 
    before do
      stub_const("Figaro", double)
      allow(Figaro).to receive_message_chain(:env, :curate_worker_tmpdir) { Dir.mktmpdir }
      allow(Figaro).to receive_message_chain(:env, :bendo_api_key) { 'top_secret' }
      allow(datastream).to receive(:dsLocation) { "http://bendo_fake/testfilename.zip" }
      allow(datastream).to receive(:content) { dataStringIo  }
    end
    it 'Returns a String for non-bendo content' do
      allow(datastream).to receive(:controlGroup) { "M"  }
      expect(datastream.determine_filesource).to eq(dataStringIo)
    end
    it 'Returns a FileIo for bendo content' do
    end
    it 'Handles Bendo 504 timeouts' do
    end
  end
end

