require Curate::Engine.root.join('app/controllers/curation_concern/base_controller')
require Curate::Engine.root.join('app/services/curation_concern')
class CurationConcern::SeniorThesesController < CurationConcern::BaseController
  respond_to(:html)
  layout 'curate_nd/1_column'

  rescue_from Citation::InvalidCurationConcern do |exception|
    redirect_to polymorphic_path([:curation_concern, curation_concern], :action => "edit"), notice: "Could not show citation. #{exception.message}"
  end
    
  def curation_concern
    @curation_concern ||=
    if params[:id]
      SeniorThesis.find(params[:id])
    else
      SeniorThesis.new(params[:senior_thesis])
    end
  end

  def new
    # @WIP - this should be extracted to the model, but that is not ideal at
    # present
    unless params[:senior_thesis]
      curation_concern.date_created = Date.today.to_s("%Y-%m-%d")
      curation_concern.rights = "All rights reserved"
      curation_concern.visibility = AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
      curation_concern.assign_doi = true
      curation_concern.language = ['English'] if curation_concern.language.empty?
      curation_concern.publisher = ['University of Notre Dame'] if curation_concern.publisher.empty?
    end
  end

  def create
    if verify_acceptance_of_user_agreement!
      begin
        @curation_concern = SeniorThesis.new(pid: CurationConcern.mint_a_pid)
        actor.create!
        redirect_to dashboard_index_path
        flash[:curation_concern_pid] = curation_concern.pid
      rescue ActiveFedora::RecordInvalid
        respond_with([:curation_concern, curation_concern]) do |wants|
          wants.html { render 'new', status: :unprocessable_entity }
        end
      end
    end
  end

  def verify_acceptance_of_user_agreement!
    if contributor_agreement.is_being_accepted?
      return true
    else
      # Calling the new action to make sure we are doing our best to preserve
      # the input values; Its a stretch but hopefully it'll work
      self.new
      respond_with([:curation_concern, curation_concern]) do |wants|
        wants.html {
          flash.now[:error] = "You must accept the contributor agreement"
          render 'new', status: :conflict
        }
      end
      return false
    end
  end
  protected :verify_acceptance_of_user_agreement!

  def show
    respond_with(curation_concern)
  end

  def edit
    respond_with(curation_concern)
  end

  def update
    actor.update!
    respond_with([:curation_concern, curation_concern])
  rescue ActiveFedora::RecordInvalid
    respond_with([:curation_concern, curation_concern]) do |wants|
      wants.html { render 'edit', status: :unprocessable_entity }
    end
  end

  def destroy
    title = curation_concern.to_s
    curation_concern.destroy
    flash[:notice] = "Deleted #{title}"
    respond_with { |wants|
      wants.html { redirect_to dashboard_index_path }
    }
  end

  include Morphine
  register :actor do
    CurationConcern.actor(curation_concern, current_user,params[:senior_thesis])
  end
end
