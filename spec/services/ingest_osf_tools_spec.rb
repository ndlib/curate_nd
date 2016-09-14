require 'spec_helper'

RSpec.describe IngestOSFTools do
  let(:all_jobs) do
    [
      { job: "Job1", status: "success" },
      { job: "Job2", status: "error" },
      { job: "Job3", status: "queue" },
      { job: "Job4", status: "processing" },
      { job: "Job5", status: "ready" },
    ]
  end

  describe '#create_osf_job' do
    it 'creates the job using BatchIngestor'
  end

  describe '#get_osf_jobs' do
    let(:subject) { IngestOSFTools.get_osf_jobs }

    before(:each) do
      allow_any_instance_of(BatchIngestor).to receive(:get_jobs).and_return(all_jobs)
    end

    it 'filters to incomplete jobs' do
      jobs = subject
      expect(jobs).not_to include({ job: "Job1", status: "success" })
      expect(jobs).to include({ job: "Job2", status: "error" })
      expect(jobs).to include({ job: "Job3", status: "queue" })
      expect(jobs).to include({ job: "Job4", status: "processing" })
      expect(jobs).to include({ job: "Job5", status: "ready" })
    end

    it 'filters to just OSF Archive jobs'
  end
end
