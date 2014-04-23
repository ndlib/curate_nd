class Admin::MasqueradesController < Devise::MasqueradesController

  def back
    super
    flash[:alert] = "Masquerade stopped. You are now acting as yourself."
  end

  private
  def after_masquerade_path_for(resource)
    start_masquerading_admin_accounts_path
  end

end

