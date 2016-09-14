require 'spec_helper'

RSpec::Matchers.define :a_put do |expected_path|
  match { |actual| actual.path == expected_path }
  description { |actual| "Expected a put to #{expected_path}, got #{actual.path} instead." }
  failure_message { |actual| "Expected a put to #{expected_path}, got #{actual.path} instead." }
end

RSpec::Matchers.define :a_put_with do |expected_body|
  match { |actual| actual.body == expected_body }
  description { |actual| "Expected a put with body of #{expected_body}, got #{actual.body} instead." }
  failure_message { |actual| "Expected a put with body of #{expected_body}, got #{actual.body} instead." }
end

RSpec.describe BatchIngestor do

  describe '.default_job_id_builder' do
    it 'will leverage the current time' do
      as_of = Time.new(2016, 9, 13, 14, 25, 42, "+00:00")
      expect(described_class.default_job_id_builder('prefix', as_of)).to eq('prefix_20160913T142542Z')
    end
  end

  describe '#submit_ingest' do
    let(:subject) do
      described_class.new(http: http, job_id_builder: job_id_builder).submit_ingest('job_id', 'task', 'file_name', ['abcde', 'defgh', 'ijklm'])
    end
    let(:response) { instance_double(Net::HTTPResponse, code: '200') }
    let(:http) { instance_double(Net::HTTP, request_post: response) }
    let(:job_id_builder) { lambda { |job_id_prefix| "#{job_id_prefix}_mock_id" } }

    it 'submits 4 correctly ordered requests' do
      expect(http).to receive(:request)
        .with(a_put('/jobs/job_id_mock_id'))
        .and_return(response)
        .ordered
      expect(http).to receive(:request)
        .with(a_put('/jobs/job_id_mock_id/files/file_name'))
        .and_return(response)
        .ordered
      expect(http).to receive(:request)
        .with(a_put('/jobs/job_id_mock_id/files/JOB'))
        .and_return(response)
        .ordered
      expect(http).to receive(:request_post)
        .with('/jobs/job_id_mock_id/queue','submit')
        .and_return(response)
        .ordered
      subject
    end

    let(:unsuccessful_response) { instance_double(Net::HTTPResponse, code: 500) }
    it 'will report to Airbrake if response code not 200' do
      expect(http).to receive(:request).with(kind_of(Net::HTTP::Put)).and_return(unsuccessful_response)
      expect(Airbrake).to receive(:notify_or_ignore)
      expect { subject }.to raise_error(BatchIngestor::BatchIngestHTTPError)
    end

    it 'submits the content data' do
      allow(http).to receive(:request)
        .and_return(response)
        .at_least(:once)
      expect(http).to receive(:request)
        .with(a_put_with('["abcde","defgh","ijklm"]'))
        .and_return(response)
        .once
      subject
    end

    it 'submits the task list' do
      allow(http).to receive(:request)
        .and_return(response)
        .at_least(:once)
      expect(http).to receive(:request)
        .with(a_put_with('{"Todo":["task"]}'))
        .and_return(response)
        .once
      subject
    end
  end


  describe '#get_osf_url' do
    let(:subject) { described_class.get_osf_url('abcde') }
    it 'correctly generates a project_url' do
      expect(subject).to eq('https://osf.io/abcde/')
    end
  end

  it 'appends the content data with a project url' do
    expect_any_instance_of(described_class).to receive(:submit_ingest).with('osfarchive', 'start-osf-archive-ingest', 'osf_projects', { project_identifier: 'abcde', project_url: 'https://osf.io/abcde/' }).and_return(true)
    described_class.start_osf_archive_ingest( project_identifier: 'abcde')
  end

  describe '#get_jobs' do
    let(:response_body) do
      "[
        { \"job\" : \"Job1\", \"status\" : \"Status1\" },
        { \"job\" : \"Job2\", \"status\" : \"Status2\" }
      ]"
    end
    let(:expected_array) do
      [
        { job: "Job1", status: "Status1" },
        { job: "Job2", status: "Status2" }
      ]
    end
    let(:response) { instance_double(Net::HTTPResponse, code: '200', body: response_body) }
    let(:http) { instance_double(Net::HTTP, request_get: response) }
    let(:subject) { described_class.new(http: http).get_jobs }

    it 'returns symbolized copy of the response from the API, without any other transformations' do
      expect(subject).to eq(expected_array)
    end

    it 'treats empty string response as an empty list of jobs' do
      allow(response).to receive(:body).and_return('')
      expect(subject).to eq([])
    end

    it 'treats nil response as an empty list of jobs' do
      allow(response).to receive(:body).and_return(nil)
      expect(subject).to eq([])
    end

    it 'handles empty array response' do
      allow(response).to receive(:body).and_return('[]')
      expect(subject).to eq([])
    end

    it 'throws an exception for invalid JSON responses' do
      allow(response).to receive(:body).and_return('some weird response')
      expect{ subject }.to raise_error
    end

    it 'throws an exception if the response code is anything other than a 200 and notifies Airbrake' do
      allow(response).to receive(:code).and_return('x')
      expect(Airbrake).to receive(:notify_or_ignore)
      expect{ subject }.to raise_error(BatchIngestor::BatchIngestHTTPError)
    end
  end
end
