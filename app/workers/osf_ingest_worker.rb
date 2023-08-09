# Probably will mostly do some sort of translation to batch ingest tool
# For now it just manipulates a class variable
class OsfIngestWorker
  def self.create_osf_job(archive, queue: default_queue)
    # I prefer to push a primitive object into the queue. It ensures that there are not state
    # mutations between enqueuing and dequeuing; This is important when dealing with an ActiveRecord object
    worker = new(archive.as_hash)
    queue.push(worker)
  end

  def self.default_queue
    Sufia.queue
  end

  attr_reader :attributes
  def initialize(attributes = {})
    @attributes = attributes
  end

  def run
    BatchIngestor.start_osf_archive_ingest(attributes, job_id_prefix: "osfarchive_#{attributes.fetch(:project_identifier)}_")
  rescue StandardError => exception
    
    raise exception
  end
end
