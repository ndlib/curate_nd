module Api
  class WorkMetadataFormatter
    attr_reader :work_id, :remaining_content

    def initialize(content:)
      @work_id = content[:work_id]
      @remaining_content = content.except(:work_id)
    end

    def valid?
      return false unless work_id
      true
    end

    def initial_metadata
      metadata_hash = remaining_content
      metadata_hash['@context'] = {} if metadata_hash['@context'].nil?
      metadata_hash['@context']['@id'] = "und:#{work_id}"
      JSON.dump(metadata_hash)
    end
  end
end
