module Api
  class FileMetadataFormatter
    attr_reader :work_id, :file_id, :file_name, :remaining_content

    def initialize(content:)
      @work_id = content[:work_id]
      @file_id = content[:file_id]
      @file_name = content[:file_name]
      @remaining_content = content.except(:work_id, :file_id, :file_name)
    end

    def valid?
      return false unless work_id
      return false unless file_id
      return false unless file_name
      true
    end

    def initial_metadata
      metadata_hash = remaining_content
      metadata_hash['@context'] = {}
      metadata_hash['@context']['@id'] = "und:#{file_id}"
      metadata_hash['nd:filename'] = "#{file_name}"
      metadata_hash['dc:title'] = "#{file_name}"
      metadata_hash['frels:isPartOf'] = "und:#{work_id}"
      JSON.dump(metadata_hash)
    end
  end
end
