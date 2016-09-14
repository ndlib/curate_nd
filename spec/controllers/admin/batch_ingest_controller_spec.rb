require 'spec_helper'

describe Admin::BatchIngestController, type: :controller do
  describe "#index" do
    let(:subject) { get :index }

    it "assigns @jobs using BatchIngestor#get_jobs" do
      allow_any_instance_of(BatchIngestor).to receive(:get_jobs).and_return("stuff from BatchIngestor.get_jobs")
      subject
      expect(assigns(:jobs)).to eq("stuff from BatchIngestor.get_jobs")
    end
  end
end
