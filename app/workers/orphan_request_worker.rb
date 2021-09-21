class OrphanRequestWorker
  def queue_name
    :help_request_notifications
  end

  attr_accessor :request_id

  def initialize(request_id)
    self.request_id = request_id
   end

  def run
    request = OrphanFileRequest.find(request_id)
    OrphanRequestMailer.notify(request).deliver
  end
end
