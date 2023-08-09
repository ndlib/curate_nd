require 'json'
require 'net/http'
require 'time'

class BatchIngestor
  class BatchIngestHTTPError < RuntimeError
  end

  attr_reader :job_id, :http, :job_id_builder

  def self.start_reingest(content_data, options = {})
    job_id_prefix = 'reingest'
    task_function_name = 'start-reingest'
    content_map = {}
    content_map['fedora-pids'] = content_data
    new(options).submit_ingest(job_id_prefix, task_function_name, content_map)
  end

  def self.start_api_ingest(trx_id, options = {})
    job_id_prefix = 'api-ingest'
    task_function_name = 'start-api-ingest'
    content_map = {}
    content_map['api_transactions'] = { "trx_id": "#{trx_id}" }
    new(options).submit_ingest(job_id_prefix, task_function_name, content_map)
  end

  def self.submit_fedora_only(work_files, generic_files, options ={})
    job_id_prefix = 'fedora-only'
    task_function_name = 'start-fedora-only'
    content_map = {}
    content_map['works-pids']= work_files
    content_map['genericfile-pids']= generic_files
    new(options).submit_ingest(job_id_prefix, task_function_name, content_map)
  end

  def self.start_osf_archive_ingest(content_data, options = {})
    job_id_prefix = options.fetch(:job_id_prefix) { "osfarchive" }
    task_function_name = 'start-osf-archive-ingest'
    content_file_name = 'osf_projects'
    content_map = {}
    content_map['osf_projects'] = content_data
    new(options).submit_ingest(job_id_prefix, task_function_name, content_map)
  end

  def self.default_job_id_builder(job_id_prefix, as_of = Time.now.utc)
    # Conforming to ISO 8601 standard [https://en.wikipedia.org/wiki/ISO_8601]
    time_format = job_id_prefix + '_%Y%m%dT%H%M%SZ'
    return as_of.strftime(time_format)
  end

  def self.get_jobs(filters = { name: /.*/, status: /.*/ }, options = {})
    new(options).jobs(filters)
  end

  def initialize(options = {})
    @http = options.fetch(:http) { default_http }
    @job_id_builder = options.fetch(:job_id_builder) { self.class.method(:default_job_id_builder) }
  end

  def submit_ingest(job_id_prefix, task_function_name, content_map)
    job_id = job_id_builder.call(job_id_prefix)
    create_batch_job(job_id)
    content_map.each do |file_name, file_data|
      add_job_file(job_id, file_name, file_data)
    end
    add_job_file(job_id, 'JOB', { 'Todo' => [task_function_name] })
    submit_batch_job(job_id)
  end

  def jobs(filters)
    response = http.request_get('/jobs')
    handle_response({}, response)
    if response.body.present?
      all_jobs = JSON.parse(response.body, symbolize_names: true)
      all_jobs.select do |job|
        filters[:name] =~ job[:Name] && filters[:status] =~ job[:Status]
      end
    else
      []
    end
  end

  private

  def default_http
    uri = URI.parse(Figaro.env.batch_ingestor_url)
    Net::HTTP.new(uri.host, uri.port)
  end

  # does PUT /jobs/:jobid to create data dir on batch ingest side
  def create_batch_job(job_id)
    request = Net::HTTP::Put.new("/jobs/#{job_id}")
    response = http.request(request)
    handle_response({ request_method: request.method, request_path: request.path }, response)
  end

  # does PUT /jobs/:jobid to create data dir on batch ingest side
  def add_job_file(job_id, filename, data)
    request = Net::HTTP::Put.new("/jobs/#{job_id}/files/#{filename}")
    request.body = JSON.generate(data)
    response = http.request(request)
    handle_response({ request_method: request.method, request_path: request.path, request_body: request.body }, response)
  end

  # does POST /jobs/:jobid/queue to start process on batch ingest side
  def submit_batch_job(job_id)
    request_path = "/jobs/#{job_id}/queue"
    request_body = "submit"
    response = http.request_post(request_path, request_body)
    handle_response({ request_method: 'POST', request_path: request_path, request_body: request_body }, response)
  end

  def handle_response(params, response)
    return true if response.code.to_s == '200'
    report_to_error_handler(params, response.code)
  end

  def report_to_error_handler(params, code)
    exception = BatchIngestHTTPError.new("HTTP request failed with status #{code} for\n\t#{params.inspect}")
    
    raise exception
  end
end
