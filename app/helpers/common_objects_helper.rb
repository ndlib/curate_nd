module CommonObjectsHelper
  def common_object_partial_for(object)
    object.to_partial_path.sub(/\A.*\/([^\/]*)\Z/,'common_objects/\1')
  end

  def removal_request_received_for?(object)
    return true if OrphanFileRequest.where(file_id: object.noid).count > 0
    false
  end
end