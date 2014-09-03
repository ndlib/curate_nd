class StaticPagesController < ApplicationController
  with_themed_layout '1_column'
  respond_to(:html)

  SUCCESS_NOTICE = "Thank you for your input! We’ve logged this occurrence and will look into it shortly."

  FAILURE_NOTICE = "Failed to create help request."

  def about
  end

  def beta
  end

  def timeout
    help_request=build_help_request
    if help_request.save
      flash_message = SUCCESS_NOTICE
    else
      flash_message = FAILURE_NOTICE
    end
    respond_with(help_request) do |wants|
      wants.html { redirect_to catalog_index_path, notice: flash_message}
    end
  end

  def help_request
    @help_request ||= build_help_request
  end
  helper_method :help_request

  private

  def build_help_request
    help_request = HelpRequest.new()
    help_request.attributes = params.require(:help_request).permit(
          :current_url,
          :flash_version,
          :how_can_we_help_you,
          :javascript_enabled,
          :resolution,
          :user_agent,
          :view_port
      )
    help_request.release_version = Curate.configuration.build_identifier
    help_request.user = current_user
    help_request
  end
end
