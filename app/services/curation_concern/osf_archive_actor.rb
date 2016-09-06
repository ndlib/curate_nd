module CurationConcern
  class OsfArchiveActor < GenericWorkActor
    def create
      record_editors = attributes.delete('record_editors_attributes')
      groups = attributes.delete('record_editor_groups_attributes')
      record_viewers = attributes.delete('record_viewers_attributes')
      record_viewer_groups = attributes.delete('record_viewer_groups_attributes')

      assign_pid && super 
    end
  end
end
