require 'json'
require 'net/http'
require 'time'

class BatchIngestor
  class BatchIngestHTTPError < RuntimeError
  end

  attr_reader :job_id, :http, :job_id_builder

  SERVER_URL = 'http://localhost:15000/'.freeze

  def self.start_reingest(content_data, options = {})
    job_id_prefix = 'reingest'
    task_function_name = 'start-reingest'
    content_file_name = 'fedora_pids'
    new(options).submit_ingest(job_id_prefix, task_function_name, content_file_name, content_data)
  end

  def self.start_osf_archive_ingest(content_data, options = {})
    job_id_prefix = 'osfarchive'
    task_function_name = 'start-osf-archive-ingest'
    content_file_name = 'osf_projects'
    content_data[:project_url] = get_osf_url(content_data.fetch(:project_identifier))
    new(options).submit_ingest(job_id_prefix, task_function_name, content_file_name, content_data)
  end

  def self.get_osf_url(project_identifier)
    'https://osf.io' + '/' + project_identifier + '/'
  end

  def self.default_job_id_builder(job_id_prefix, as_of = Time.now.utc)
    # Conforming to ISO 8601 standard [https://en.wikipedia.org/wiki/ISO_8601]
    time_format = job_id_prefix + '_%Y%m%dT%H%M%SZ'
    return as_of.strftime(time_format)
  end

  def initialize(options = {})
    @http = options.fetch(:http) { default_http }
    @job_id_builder = options.fetch(:job_id_builder) { self.class.method(:default_job_id_builder) }
  end

  def submit_ingest(job_id_prefix, task_function_name, content_file_name, content_data)
    job_id = job_id_builder.call(job_id_prefix)
    create_batch_job(job_id)
    add_job_file(job_id, content_file_name, content_data)
    add_job_file(job_id, 'JOB', { 'Todo' => [task_function_name] })
    submit_batch_job(job_id)
  end

  def get_jobs
    response = http.request_get('/jobs')
    handle_response({}, response)
    if response.body.present?
      JSON.parse(response.body, symbolize_names: true)
    else
      []
    end
  end

  private

  def default_http
    uri = URI.parse(SERVER_URL)
    Net::HTTP.new(uri.host, uri.port)
  end

  # does PUT /jobs/:jobid to create data dir on batch ingest side
  def create_batch_job(job_id)
    request = Net::HTTP::Put.new("/jobs/#{job_id}")
    response = http.request(request)
    handle_response('create_batch_job', response)
  end

  # does PUT /jobs/:jobid to create data dir on batch ingest side
  def add_job_file(job_id, name, data)
    request = Net::HTTP::Put.new("/jobs/#{job_id}/files/#{name}")
    request.body = JSON.generate(data)
    response = http.request(request)
    handle_response({ task_name: name, method_name: 'add_job_file', job_input: data }, response)
  end

  # does POST /jobs/:jobid/queue to start process on batch ingest side
  def submit_batch_job(job_id)
    response = http.request_post("/jobs/#{job_id}/queue", "submit")
    handle_response('submit_batch_job', response)
  end

  def handle_response(params, response)
    return true if response.code.to_s == '200'
    report_to_airbrake(params, response.code)
  end

  def report_to_airbrake(params, code)
    exception = BatchIngestHTTPError.new("HTTP request failed with status #{code}")
    Airbrake.notify_or_ignore(error_class: exception.class, error_message: exception, parameters: params)
    raise exception
  end
end
