require 'json'
require 'net/http'
require 'time'
require 'uri'

# Use Batch Ingest HTTP Interface to submit modified fedora objects
# that contain bendo items to batch ingest system, for possible reingest
class BatchIngestTools

  def self.submit_pidlist(pid_list)

    make_job_id
    create_batch_job
    add_job_file('fedora-pids', pid_list)
    submit_batch_job

  end

  def self.make_job_id
    @job_id = Time.now.strftime 'reingest%Y%b%e%H%M%s'
  end

  # does PUT /jobs/:jobid to create data dir on batch ingest side
  def self.create_batch_job
    url = 'http://localhost:15000/jobs/' + @job_id
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.path)
    http.request(request)
  end

  # does PUT /jobs/:jobid to create data dir on batch ingest side
  def self.add_job_file(name, content)
    url = 'http://localhost:15000/jobs/' + @job_id + "/files/" + name
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.path)
    request.body = content.to_s
    http.request(request)
  end

  # does POST /jobs/:jobid/queue to start process on batch ingest side
  def self.submit_batch_job
    url = 'http://localhost:15000/jobs/' + @job_id + "/queue"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    http.request_post(uri.path, 'submit') { |response|
	p response.code
    }
  end
end