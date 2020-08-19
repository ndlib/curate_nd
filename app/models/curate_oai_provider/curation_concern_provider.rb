class CurateOaiProvider
  class CurationConcernProvider < OAI::Provider::Model
    def initialize(controller: nil)
      @identifier_field = 'identifier'
      @timestamp_field = 'timestamp'
      @controller = controller
      @limit = begin
        Rails.configuration.default_oai_limit
      rescue NoMethodError
        100
      end
    end
    attr_reader :controller, :limit

    def earliest
      Time.zone.at(0)
    end

    def latest
      Time.current + 1.second
    end

    def find(selector, options = {})
      if selector == :all
        response_data = begin
          if options[:resumption_token]
            options = next_set(options[:resumption_token])
          end
          load_data(options.merge(rows: limit))
        end
        wrap_results(response_data, options)
      else
        begin
          format_response_terms(ActiveFedora::Base.find(selector, cast: true))
        rescue ActiveFedora::ObjectNotFoundError
          return nil
        end
      end
    end

    def load_data(options = {})
      if valid_search_request_syntax?(options)
        controller.params.merge!(options)
        # returns [ Blacklight::SolrResponse, Array(SolrDocument) ]
        (response, document_list) = controller.get_search_results
      else
        raise OAI::ArgumentException
      end
    end

    def valid_search_request_syntax?(options)
      Oai::QueryBuilder.new.valid_request?(options)
    end

    def next_set(token_string)
      token = OAI::Provider::ResumptionToken.parse(token_string)
      token.to_conditions_hash.merge(page: token.last)
    end

    def wrap_results(response_data, options)
      return nil if response_data.nil?
      response = response_data.first
      document_list = response_data.last
      formatted_results = format_response_list(document_list)
      if response_data.first.last_page?
        formatted_results
      else
        OAI::Provider::PartialResult.new(
        formatted_results,
        OAI::Provider::ResumptionToken.new(options.merge(last: response.next_page))
      )
      end
    end

    def format_response_terms(record)
      # record.map_to(controller.params["metadataPrefix"])
      response_object = record.standardize
      response_object[:timestamp] = response_object[:date_modified].to_time
      response_object[:source] = File.join(Rails.configuration.application_root_url, 'show', record.noid)
      Struct.new(*response_object.keys).new(*response_object.values)
    end

    def format_response_list(record_list)
      formatted_list = []
      record_list.map(&:to_model).each do |item|
        formatted_list  << format_response_terms(item)
      end
      formatted_list
    end

    def sets
      sets_array = []
      Curate.configuration.registered_curation_concern_types.sort.collect(&:constantize).each do |curation_concern|
        sets_array.push({ spec: "model:#{curation_concern}",
                       name: curation_concern.to_s,
                       description: "All model #{curation_concern.human_readable_type} objects" })
      end
      LibraryCollection.all.each do |collection|
        sets_array.push({ spec: "collection:#{collection.id}",
                       name: "Collection: #{collection.title}",
                       description: collection.description })
      end
      sets_array.push({ spec: "primo",
                     name: "Primo",
                     description: "All items included in Primo import" })
      set_list = []
      sets_array.each do |values|
        set_list.push(OAI::Set.new(values))
      end
      set_list
    end

    # used by oai gem to override methods to load the response terms
    # => response_term: :key_in_our_object
    def map_oai_dc
      # @fields = [ :title, :creator, :subject, :description, :publisher,
      #         :contributor, :date, :type, :format, :identifier,
      #         :source, :language, :relation, :coverage, :rights]
      {
        type: :worktype,
        publisher: :administrative_unit,
        date: :date_modified
      }
    end
    def map_dcterms
      {
        type: :worktype,
        publisher: :administrative_unit,
        dateSubmitted: :date_deposited,
        created: :date_created,
        modified: :date_modified,
        isPartOf: :is_part_of,
        bibliographicCitation: :doi
      }
    end

    class Dcterms < ::OAI::Provider::Metadata::Format
      def initialize
        @prefix = 'dcterms' # This prefix is important for registered formats
        @schema = 'https://www.dublincore.org/schemas/xmls/qdc/2008/02/11/dcterms.xsd'
        @namespace = 'http://purl.org/dc/terms/'
        @element_namespace = 'dcterms'
        @fields = [:identifier,
                   :type,
                   :dateSubmitted,
                   :created,
                   :modified,
                   :title,
                   :creator,
                   :author,
                   :subject,
                   :description,
                   :publisher,
                   :contributor,
                   :format,
                   :source,
                   :language,
                   :relation,
                   :coverage,
                   :rights,
                   :isPartOf,
                   :bibliograpicCitation]
      end

      def header_specification
        {
          'xmlns:oai_dcterms' => "http://purl.org/dc/terms/",
          'xmlns:dcterms' => "http://purl.org/dc/elements/1.1/",
          'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
          'xsi:schemaLocation' =>
            %{http://purl.org/dc/terms/
              https://www.dublincore.org/schemas/xmls/qdc/2008/02/11/dcterms.xsd}.gsub(/\s+/, ' ')
        }
      end
    end
  end
end
