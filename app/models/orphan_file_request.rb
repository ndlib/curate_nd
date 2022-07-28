class OrphanFileRequest < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :user_email, :file_id, :work_id
  validates_uniqueness_of :file_id
  after_create :send_notification

  def mark_completed_by(updating_user)
    update(completed_date: Time.now, updating_user_id: updating_user.id)
  end

  def request_completed?
    return false if completed_date.blank?
    true
  end

  private

  def send_notification
    Sufia.queue.push(NotificationWorker.new(id, :orphan))
  end
end
