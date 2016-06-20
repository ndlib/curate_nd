require 'curate/indexer'

# Responsible for reindexing a single PID and its relationships
class ObjectRelationshipReindexerWorker
  def queue_name
    :resolrize
  end

  def initialize(pid)
    @pid = pid
  end
  attr_reader :pid

  def run
    begin
      Curate::Indexer.reindex_relationships(pid)
    rescue StandardError => exception
      Harbinger.call(reporters: [exception], channels: [:database, :logger])
      raise exception
    end
  end
end
