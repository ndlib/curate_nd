require 'curate/indexer'

# Responsible for reindexing a single PID and its relationships
class AllRelationshipsReindexerWorker
  def queue_name
    :resolrize
  end

  def run
    begin
      Curate::Indexer.reindex_all!
    rescue StandardError => exception
      Sentry.capture_exception(exception)
      raise exception
    end
  end
end
