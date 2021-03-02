class StaticPagesController < ApplicationController
  with_themed_layout '1_column'
  respond_to(:html)

  def status
   @status ||= params[:status_code] || request.path.gsub('/','').to_i
  end

  helper_method :status

  def about
    @hide_title = false;
    render layout: 'curate_nd_home'
  end

  def home
    render layout: 'curate_nd_home'
  end

  def contribute
    @hide_title = false;
    render layout: 'curate_nd_home'
  end

  def error
    @help_request = build_help_request
    respond_with(@help_request) do |wants|
      wants.html { render status: status }
      wants.json { render status: status }
    end
  end

  def faqs
    @hide_title = false;
    render layout: 'curate_nd_home'
  end

  def policies
    @hide_title = false;
    render 'policies', layout: 'curate_nd_home'
  end

  def tos
    @hide_title = false;
    render 'terms_of_service', layout: 'curate_nd_home'
  end

  def licenses
    @hide_title = false;
    render 'licenses', layout: 'curate_nd_home'
  end

  def subm_agree
    @hide_title = false;
    render 'submission_agreement', layout: 'curate_nd_home'
  end

  private

  def build_help_request
    email = current_user ? current_user.email : ''
    HelpRequest.new(
      user: current_user,
      email: email,
      how_can_we_help_you:"#{t('sufia.product_name')} encountered a problem (Error ##{status})."
    )
  end

  def show_site_search?
    if params[:action] == 'home'
      false
    else
      true
    end
  end

end
