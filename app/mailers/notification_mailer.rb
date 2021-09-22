class NotificationMailer < ActionMailer::Base
  def notify(request, request_type)
    case request_type
    when :orphan
      orphan_notify(request)
    else
      help_notify(request)
    end
  end

  private

  # in order for service-now ticket to be created, subject text must begin with the following
  def service_now_subject_matcher
    "#{t('sufia.product_name')}: Help Request"
  end

  def help_notify(help_request)
    mail(from: sender_email(help_request),
        to: recipients_list,
        subject: "#{service_now_subject_matcher} - #{help_request.id} [#{Rails.env}]",
        body: prepare_body(help_request))
  end

  def prepare_body(help_request)
    body  = "From: #{sender_email(help_request)}\n"
    body += "URL: #{help_request.current_url}\n"
    body += "Javascript enabled: #{help_request.javascript_enabled}\n"
    body += "User Agent: #{help_request.user_agent}\n"
    body += "Resolution: #{help_request.resolution}\n"
    body += "Name: #{help_request.name}\n"
    body += "Message: #{help_request.how_can_we_help_you}"
    body
  end

  def orphan_notify(orphan_file_request)
    mail(from: orphan_file_request.user_email,
      to: recipients_list,
      subject: "#{service_now_subject_matcher} - Remove File #{orphan_file_request.file_id} [#{Rails.env}]",
      body: prepare_orphan_body(orphan_file_request))
  end

  def prepare_orphan_body(orphan_file_request)
    body  = "From: #{orphan_file_request.user_email}\n"
    body += "Requesting User: #{user_info(orphan_file_request.user_id)}\n"
    body += "File ID: #{orphan_file_request.file_id}\n"
    body += "Work ID: #{orphan_file_request.work_id}\n"
    body += "Message: I am requesting removal of #{t('sufia.product_name')} file #{orphan_file_request.file_id} from work id #{orphan_file_request.work_id}.\n"
    body
  end

  def recipients_list
    @list ||= Array.wrap(ENV.fetch('CURATE_HELP_NOTIFICATION_RECIPIENT'))
    return @list
  end

  def sender_email(help_request)
    help_request.sender_email.blank? ? default_sender : help_request.sender_email
  end

  def default_sender
    @sender ||= YAML.load(File.open(File.join(Rails.root, "config/smtp_config.yml")))
    return @sender[Rails.env]["smtp_user_name"]
  end

  def user_info(id)
    requesting_user = User.find(id)
    requesting_user.username + ': ' + requesting_user.name
  end
end
