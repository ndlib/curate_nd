class ReindexWorker
  FEDORA_SYSTEM_PIDS = 'fedora-system:'.freeze
  def queue_name
    :resolrize
  end

  attr_reader :pids_to_reindex

  def initialize(pid_list = nil)
    @pids_to_reindex = pid_list.nil? ? :everything : Array.wrap(pid_list)
  end

  def run
    if @pids_to_reindex == :everything
      reindex_everything
    else
      reindex_each_pid
    end
  end

  private

  def reindex_everything(query = "pid~#{Sufia.config.id_namespace}:*")
    ActiveFedora::Base.send(:connections).each do |conn|
      conn.search(query) do |object|
        next if object.pid.start_with?(FEDORA_SYSTEM_PIDS)
        Sufia.queue.push(ReindexWorker.new(object.pid))
      end
    end
  end

  def reindex_each_pid
    @pids_to_reindex.each do |pid|
      reindex_for(pid)
    end
  end

  def reindex_for(pid)
    ActiveFedora::Base.find(pid, :cast=>true).update_index
    Curate.relationship_reindexer.call(pid)
  end
end
