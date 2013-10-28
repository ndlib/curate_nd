require Curate::Engine.root.join('app/services/curation_concern')
class CurationConcern::SeniorThesesController < CurationConcern::GenericWorksController
  self.curation_concern_type = SeniorThesis

  rescue_from Citation::InvalidCurationConcern do |exception|
    redirect_to polymorphic_path([:curation_concern, curation_concern], :action => "edit"), notice: "Could not show citation. #{exception.message}"
  end

  def after_create_response
    flash[:curation_concern_pid] = curation_concern.pid
    super
  end

  def setup_form
    true
  end
end
