class UsersController < ApplicationController
  respond_to(:html)
  layout 'curate_nd/1_column'

  def update
    update_user!
    redirect_to dashboard_index_path, :notice =>"You updated your account successfully."
  end

  private

  def update_user!
    user.update_attributes(params['user'])
    user.save!
  end

  def user
    @user ||= User.find(params[:id])
  end
end
