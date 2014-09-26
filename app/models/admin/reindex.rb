class Admin::Reindex
  def initialize(pid_list)
    @pid_list = pid_list
  end
  
  def add_to_work_queue
    until @pid_list.empty? do
      batch = @pid_list.slice!(0,10)
      Sufia.queue.push(ReindexWorker.new(batch))
    end
  end
end
