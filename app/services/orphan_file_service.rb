class OrphanFileService
  def self.orphan_file(file_id:, requested_by:)
    return false unless requested_by.can?(:orphan, GenericFile)
    @object = find_object(file_id)
    return false unless @object
    remove_parent!
    @object = find_object(file_id) #reload updated object
    @object.update_index
    OrphanFileRequest.where(file_id: @object.noid).first.mark_completed_by(requested_by)
    true
  end

  private

  def self.remove_parent!
    ds = @object.datastreams["RELS-EXT"].to_rels_ext
    ds_array = ds.lines
    ds_array.each do |line|
        ds_array -= [line] if line.include?('fedora-relations-model:isPartOf')
    end
    newds = ds_array.join('')
    @object.datastreams["RELS-EXT"].content = newds
    @object.save
    true
  end

  def self.find_object(file_id)
    begin
      abc = GenericFile.find(file_id)
    rescue ActiveFedora::ObjectNotFoundError
      return nil
    end
  end
end
