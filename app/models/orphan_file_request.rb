class OrphanFileRequest < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :user_email, :file_id, :work_id
  validates_uniqueness_of :file_id
  after_create :send_notification

  def mark_completed
    update_attribute(:completed_date, Time.now)
  end

  private

  def send_notification
    Sufia.queue.push(NotificationWorker.new(id, :orphan))
  end
end
