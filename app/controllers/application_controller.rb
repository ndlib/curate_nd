class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
   include Blacklight::Controller
  include CurateController

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :filter_notify
  before_filter :allow_whitelisted_users

  def filter_notify
    # remove error inserted since we are not showing a page before going to web access, this error message always shows up a page too late.
    # for the moment just remove it always.  If we show a transition page in the future we may want to  display it then.
    if flash[:alert].present?
      flash[:alert] = [flash[:alert]].flatten.reject do |item|
        item == "You need to sign in or sign up before continuing."
      end
      flash[:alert] = nil if flash[:alert].blank?
    end
  end

  private
  def user_whitelisted?
    current_user && current_user.whitelisted?
  end

  def allow_whitelisted_users
    if user_whitelisted?
      return true
    else
      if( ["classify_concerns", "cas_sessions", "terms_of_service_agreements", "registrations"].include?(controller_name))
        return true
      elsif ["edit", "new", "update", "destroy"].include?(action_name)
        redirect_to root_url, notice: "You do not have sufficient permissions for this action"
        return false
      else
        return request.get?
      end
    end
  end
end
