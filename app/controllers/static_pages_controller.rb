class StaticPagesController < ApplicationController
  with_themed_layout '1_column'
  respond_to(:html)

  def about
  end

  def beta
  end

  def timeout_error
    @help_request = HelpRequest.new(user: current_user)
    respond_with(@help_request) do |wants|
      wants.html { render status: 502 }
      wants.json { render status: 502 }
    end
  end
end
