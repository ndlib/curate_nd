require 'csv'
# Responsible for formating csv results from a Blacklight search response
class ExportCsvPresenter
  SOLR_DOC_MAP = {
    id: ["id"],
    type: ["human_readable_type_tesim"],
    title: ["desc_metadata__title_tesim"],
    admin_unit: ["desc_metadata__administrative_unit_tesim"],
    creator: ["desc_metadata__creator_tesim", "desc_metadata__author_tesim", "desc_metadata__work_author_tesim"],
    created: ["desc_metadata__date_created_tesim"],
    description: ["desc_metadata__description_tesim", "desc_metadata__abstract_tesim"]
  }
  attr_reader :documents

  def initialize(raw_response)
    @documents = raw_response.fetch('response').fetch('docs')
  end

  # @return [Array]
  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << SOLR_DOC_MAP.keys
      @documents.each do |item|
        csv << SOLR_DOC_MAP.values.map{ |attr_array| load_attributes(item, attr_array) }
      end
    end
  end

  private

    # load the values for one key from the key's attribute array
    def load_attributes(item, attr_array)
      combined_value = ''
      attr_array.each do |attr|
        val = item.has_key?(attr) ? formatted_value_for_output(item[attr], attr) : ''
        combined_value = join_values(combined_value, val)
      end
      combined_value
    end

    def join_values(value1, value2, connector = ',')
      return value1 if value2.blank?
      value2 = (value2.is_a?(Array) ? value2.join(connector) : value2).gsub('University of Notre Dame::', '')
      value1.blank? ? value2 : value1 + connector + value2
    end

    def formatted_value_for_output(attribute_value, attr)
      case attr
      when "id"
        return convert_to_url(attribute_value)
      else
        return attribute_value
      end
    end

    def convert_to_url(val)
      base_url = Rails.configuration.application_root_url
      base_url + '/show/' + val
    end
end
