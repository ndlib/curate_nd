class ReindexWorker
  def queue_name
    :resolrize
  end

  def initialize(pid_list=nil)
    @pids_to_reindex = case
                       when pid_list.nil?
                         :everything
                       when pid_list.respond_to?(:each)
                         pid_list
                       else
                         [pid_list]
                       end
  end

  def run
    if @pids_to_reindex == :everything
      ActiveFedora::Base.reindex_everything("pid~#{Sufia.config.id_namespace}:*")
    else
      @pids_to_reindex.each do |pid|
        ActiveFedora::Base.find(pid, :cast=>true).update_index
      end
    end
  end
end
