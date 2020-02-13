class CurationConcern::DissertationsController < CurationConcern::GenericWorksController
  self.curation_concern_type = Dissertation

  def setup_form
    if action_name == 'new'
      curation_concern.creator << current_user.name if curation_concern.creator.empty? && !current_user.can_make_deposits_for.any?
      curation_concern.record_editors << current_user.person unless curation_concern.record_editors.present?
    end
    curation_concern.record_editors.build
    curation_concern.record_editor_groups.build
    curation_concern.record_viewers.build
    curation_concern.record_viewer_groups.build
    curation_concern.build_contributor if curation_concern.contributor.blank?
  end
  protected :setup_form

end
