require Curate::Engine.root.join('app/models/help_request')
class HelpRequest
  def sender_email
    self.user.email || I18n.t('sufia.help_email')
  end
end
