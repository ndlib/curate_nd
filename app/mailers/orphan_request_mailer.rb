class OrphanRequestMailer < ActionMailer::Base

  def notify(orphan_file_request)
    mail(from: orphan_file_request.user_email,
      to: recipients_list,
      subject: "#{t('sufia.product_name')}: Orphan File Request - File ID #{orphan_file_request.file_id} [#{Rails.env}]",
      body: prepare_body(orphan_file_request))
  end

  private

  def prepare_body(orphan_file_request)
    body  = "From: #{orphan_file_request.user_email}\n"
    body += "Requesting User: #{user_info(orphan_file_request.user_id)}\n"
    body += "File ID: #{orphan_file_request.file_id}\n"
    body += "Work ID: #{orphan_file_request.work_id}\n"
    body += "Message: I am requesting removal of #{t('sufia.product_name')} file #{orphan_file_request.file_id} from work id #{orphan_file_request.work_id}.\n"
    # body += "#{t('sufia.product_name')} Url: #{Rails.configuration.application_root_url}/show/#{orphan_file_request.file_id}"
    body
  end

  def recipients_list
    @list ||= Array.wrap(ENV.fetch('CURATE_HELP_NOTIFICATION_RECIPIENT'))
    return @list
  end

  def user_info(id)
    requesting_user = User.find(id)
    requesting_user.username + ': ' + requesting_user.name
  end
end
