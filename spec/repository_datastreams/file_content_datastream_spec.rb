require 'spec_helper'
require 'fileutils'

describe FileContentDatastream do
  let(:datastream) { described_class.new }
  let(:bendo_uri) { "http://bendo_fake/testfilename.zip" }
  let(:dataStringIo) { "Datastream file stream content StrgIo" }
  let(:download_tmpdir) { Dir.mktmpdir }
  let(:header_response) { HTTP::Response.new({ headers: { 'X-Cached': '1' }, version: "1.1", status: 200, body: ' '}) }

  def create_file_and_exception
    FileUtils.touch( File.join(download_tmpdir, File.basename(bendo_uri)))
    raise Down::ServerError.new("504 Bendo Gateway Timeout")
  end

  describe '#return_file_content' do 
    before do
      stub_const("Figaro", double)
      allow(datastream).to receive(:content) { dataStringIo  }
    end
    it 'Returns a String for non-bendo content' do
      stub_const("Figaro", double)
      allow(datastream).to receive(:controlGroup) { "M"  }
      expect(datastream.return_file_content).to eq(dataStringIo)
    end
    it 'Returns a FileIo for bendo content' do
      stub_const("Figaro", double)
      allow(datastream).to receive(:controlGroup) { "R"  }
      allow(Figaro).to receive_message_chain(:env, :curate_worker_tmpdir) { download_tmpdir  }
      allow(Figaro).to receive_message_chain(:env, :bendo_api_key) { 'top_secret' }
      allow(datastream).to receive(:dsLocation) { bendo_uri }
      allow(Down::NetHttp).to receive(:download) { FileUtils.touch( File.join(Figaro.env.curate_worker_tmpdir, File.basename(bendo_uri)))}
      expect(datastream.return_file_content.is_a?(File)).to eq(true)
    end
    it 'Handles a 504 Gateway Timeout from bendo' do
      stub_const("Figaro", double)
      allow(datastream).to receive(:controlGroup) { "R"  }
      allow(Figaro).to receive_message_chain(:env, :curate_worker_tmpdir) { download_tmpdir  }
      allow(Figaro).to receive_message_chain(:env, :bendo_api_key) { 'top_secret' }
      FileUtils.touch( File.join(Figaro.env.curate_worker_tmpdir, File.basename(bendo_uri)))
      allow(datastream).to receive(:dsLocation) { bendo_uri }
      allow(HTTP).to receive(:head) { header_response }
      allow(Down::NetHttp).to receive(:download) { create_file_and_exception }
      expect { datastream.return_file_content }.to_not raise_error
    end
  end
end

