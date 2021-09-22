require 'browser'
class HelpRequest < ActiveRecord::Base

  belongs_to :user
  validates_presence_of :how_can_we_help_you,
    :message => "Please tell us about the problem or issue you are having with #{I18n.t('sufia.product_name')}."

  after_save :send_notification

  def browser_name
    parse_user_agent
    @browser.name
  end

  def form_email
    user.try(:email) || email || ''
  end

  def form_name
    user.try(:name) || name || ''
  end

  def platform
    parse_user_agent
    @browser.platform
  end

  def sender_email
    return user.email if user.try(:email)
    return email if email.present?
    ENV.fetch('CURATE_HELP_NOTIFICATION_DEFAULT_SENDER')
  end

  def user_name
    user.try(:user_key) || name || 'Unknown'
  end

  private

  def parse_user_agent
    @browser ||= Browser.new(:ua => user_agent)
  end

  def send_notification
    Sufia.queue.push(NotificationWorker.new(id, :help))
  end
end
