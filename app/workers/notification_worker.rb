class NotificationWorker
  def queue_name
    :help_request_notifications
  end

  attr_accessor :request_id, :request_type

  def initialize(request_id, request_type=:help)
    self.request_id = request_id
    self.request_type = request_type
  end

  def run
    case request_type
    when :orphan
      request = OrphanFileRequest.find(request_id)
    else
      request = HelpRequest.find(request_id)
    end
    NotificationMailer.notify(request, request_type).deliver
  end
end
