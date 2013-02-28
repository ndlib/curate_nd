class ContributorAgreement
  attr_reader :curation_concern, :user
  def initialize(curation_concern, user, params)
    @curation_concern = curation_concern
    @user = user
    @param_value = params[param_key.to_sym] || params[param_key.to_s]
  end

  def human_readable_text
    human_readable_text <<-HTML
    <p class="human_readable contributor_agreement">
      place holder for human readable text
    </p>
    HTML
  end

  def legally_binding_text
    legally_binding_text <<-HTML
    <p class="lawyer_readable contributor_agreement">
      place holder for legally binding text
    </p>
    HTML
  end

  def acceptance_value
    'accept'
  end

  def param_key
    :accept_contributor_agreement
  end
  attr_reader :param_value

  def is_being_accepted?
    param_value == acceptance_value
  end
end
