require 'hesburgh/lib/controller_with_runner'
class CurationConcern::SeniorThesesController < CurationConcern::GenericWorksController
  self.curation_concern_type = SeniorThesis
  def after_create_response
    flash[:curation_concern_pid] = curation_concern.pid
    super
  end

  def attach_action_breadcrumb
    true
  end

  def setup_form
    true
  end

  rescue_from Citation::InvalidCurationConcern do |exception|
    redirect_to polymorphic_path([:curation_concern, curation_concern], :action => "edit"), notice: "Could not show citation. #{exception.message}"
  end

  register :curation_concern do
    return @curation_concern if @curation_concern
    if params[:id]
      if curation_concern_type == ActiveFedora::Base
        curation_concern_type.find(params[:id], cast: true)
      else
        curation_concern_type.find(params[:id])
      end
    else
      curation_concern_type.new
    end
  end

  ##### ABOVE THIS LINE IS CURATE ARTIFACTS #####

  include Hesburgh::Lib::ControllerWithRunner
  self.runner_container = CurationConcern::SeniorThesisRunners

  def new
    _status, @curation_concern = run
    respond_with(@curation_concern)
  end

  def create
    run(params[:senior_thesis]) do |on|
      on.unaccepted_contributor_agreement do |form|
        flash.now[:error] = "You must accept the contributor agreement"
        @curation_concern = form
        respond_with(form)
      end
      on.failure do |form|
        @curation_concern = form
        respond_with(form)
      end
      on.success do |curation_concern|
        respond_with([:curation_concern, curation_concern])
      end
    end
  end

  def show
    @curation_concern = SeniorThesis.find(params[:id])
    respond_with([:curation_concern, curation_concern])
  end

  def repository
    Repository.new
  end

end
