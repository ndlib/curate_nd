module ApplicationHelper

  def curation_concern_collection_path(asset)
    collection_path(asset)
  end

  def curation_concern_person_path(person)
    person_path(person)
  end

  def display_as_grid?
    if (params[:display] == 'grid')
      true
    else
      false
    end
  end

  def include_rich_text_editor?
    (params[:action] == 'edit' || params[:action] == 'new' ) && params[:controller].start_with?('curation_concern')
  end
end
