class Admin::AnnouncementsController < ApplicationController
  with_themed_layout('1_column')

  before_action :set_admin_announcement, only: [:show, :edit, :update, :destroy]

  # GET /admin/announcements
  def index
    @admin_announcements = Admin::Announcement.all.page(params[:page])
  end

  # GET /admin/announcements/1
  def show
  end

  # GET /admin/announcements/new
  def new
    @admin_announcement = Admin::Announcement.new
  end

  # GET /admin/announcements/1/edit
  def edit
  end

  # POST /admin/announcements
  def create
    @admin_announcement = Admin::Announcement.new(admin_announcement_params)

    if @admin_announcement.save
      redirect_to admin_announcements_url, notice: 'Announcement was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/announcements/1
  def update
    if @admin_announcement.update(admin_announcement_params)
      redirect_to admin_announcements_url, notice: 'Announcement was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/announcements/1
  def destroy
    @admin_announcement.destroy
    redirect_to admin_announcements_url, notice: 'Announcement was successfully destroyed.'
  end

  def dismiss
    Admin::Announcement.dismiss(params[:id], current_user)
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_announcement
      @admin_announcement = Admin::Announcement.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_announcement_params
      params.require(:admin_announcement).permit(:message, :start_at, :end_at)
    end
end
