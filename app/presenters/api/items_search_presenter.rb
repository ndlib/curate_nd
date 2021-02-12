# Responsible for generating the JSON search results from a Blacklight search response
# (based on catalog_index_jsonld_presenter)
class Api::ItemsSearchPresenter
  include Sufia::Noid
  attr_reader :raw_response, :request_url, :documents, :pager, :query_parameters

  # This hash controls the data used to build results list:
    # key: a valid search, sort, or fl value. Converted to camel case in response.
    #
    # hash: {
    # => fields:  Array, required (0-n elements)
    #             solr field names to retrieve from item and combine into value for key
    # => method:  Symbol, optional - a valid method to call on item's field data.
    #             use :first for single-value fields to prevent display as array
    #             Define new methods in Transformer module below.
    # => default: String, optional
    #             value to return in case of null value in item
    # => with:    Symbol, optional (recursive limit to 3)
    #             another field to include every time given field is returned
    # }
  RESULT_DATA = {
    admin_unit:
      { fields: ["desc_metadata__administrative_unit_tesim"] },
    author:
      { fields: ["desc_metadata__author_tesim"] },
    creator:
      { fields: ["desc_metadata__creator_tesim"],
        with: :author },
    deposit_date:
      { fields: ["system_create_dtsi"],
        method: :first },
    depositor:
      { fields: ["depositor_tesim"],
        method: :first },
    doi:
      { fields: ["desc_metadata__identifier_tesim"],
        method: :first },
    editor:
      { fields: ["edit_access_person_ssim"] },
    language:
      { fields: ["desc_metadata__language_tesim"] },
    modify_date:
      { fields: ["system_modified_dtsi"],
        method: :first },
    part_of:
      { fields: ["library_collections_pathnames_tesim"] },
    representative:
      { fields: ["representative_tesim"] },
    title:
      { fields: ["desc_metadata__title_tesim"],
        method: :first,
        default: "title-not-found" },
    upload_date:
      { fields: ["desc_metadata__date_uploaded_dtsi"] },
    visibility:
      { fields: ["read_access_group_ssim"],
        method: :screen_visibility }
  }.freeze

  def initialize(raw_response, request_url, query_parameters)
    @raw_response = raw_response
    @request_url = RDF::URI.new(request_url)
    @documents = raw_response.fetch('response').fetch('docs')
    @query_parameters = query_parameters
    @pager = Pager.new(self)
    build_json!
  end
  delegate :total_results, :start, :items_per_page, :page, to: :pager

  # @return [String] the JSON document
  def to_json
    JSON.dump(@json)
  end

  # @return [Hash] a Ruby Hash of the JSON document
  def as_json
    @json
  end

  private

  def build_json!
    json = { 'query' => [],
             'results' => [],
             'pagination' => [] }
    add_query_to_graph(json)
    add_pagination_to_graph(json)
    add_documents_to_graph(json)
    @json = json
  end

  def add_query_to_graph(json)
    query_object = { 'queryUrl' => request_url.to_s,
                     'queryParameters' => query_parameters }
    json['query'] = query_object
  end

  def add_pagination_to_graph(json)
    pagination_object = { 'itemsPerPage' => items_per_page,
                          'totalResults' => total_results,
                          'currentPage' => page }
    [:first, :last, :previous, :next].each do |pagination_method|
      pager.pagination_url_for(pagination_method) do |url|
        pagination_object["#{pagination_method}"+"Page"] = url.to_s
      end
    end
    json['pagination'] = pagination_object
  end

  def add_documents_to_graph(json)
    documents.each do |document|
      document_object = SingleItemResult.new(
        item: document,
        params: query_parameters,
        request_url: request_url
      ).content
      json['results'] << document_object
    end
  end

  class SingleItemResult
    # item: a single Solr document
    # fields: list of additional fields to include from query parameters
    def initialize(item:, params:, request_url:)
      @item = item
      @params = params
      @request_url = request_url
      @fields = build_field_list
    end

    attr_reader :item, :fields, :params, :request_url

    def content
      # always include standard list of fields
      results_hash = {
        "id" => item_id,
        "title" =>  include_data_for("title"),
        "type" => dc_type,
        "itemUrl" => item_url
      }
      # load results hash for all search, sort, and requested fields
      fields.each do |field|
        begin
          results_hash[field.camelize(:lower)] = include_data_for(field)
          # return related field if one exists
          count = 0
          next_field = RESULT_DATA[field.to_sym] && RESULT_DATA[field.to_sym][:with]
          while next_field && count < 3 do
            results_hash[next_field.to_s.camelize(:lower)] = include_data_for(next_field)
            # continue if the field is valid and has a :with field
            next_field = RESULT_DATA[next_field.to_sym] && RESULT_DATA[next_field.to_sym][:with]
            count += 1
          end
        end
      end
      results_hash
    end

    def build_field_list
      field_list = []
      # first include anything in :fl
      field_list += (params[:fl].split(",")) if params[:fl].present?

      # next add any sort terms
      field_list += Array.wrap((params[:sort].split(" ")).first) if params[:sort].present?

      # next include any valid queried terms
      field_list += (params.keys.map(&:to_s) & Api::QueryBuilder::VALID_KEYS_AND_SEARCH_FIELDNAMES.keys.map(&:to_s))

      # and finally, remove the fields we automatically include, to prevent overwriting with error
      field_list -= ["id", "title", "type", "itemUrl"]

      # return compiled list of fields to include in results list
      field_list
    end

    def item_id
      @item_id ||= Sufia::Noid.noidify(@item.fetch('id'))
    end

    def dc_type
      model = Array.wrap(@item.fetch('active_fedora_model_ssi'))
      dc_type = @item.fetch('desc_metadata__type_tesim', model)
      Array.wrap(dc_type).first
    end

    def item_url
      File.join(request_url.root.to_s,  Rails.application.routes.url_helpers.api_item_path(item_id))
    end

    def include_data_for(field)
      field_data = []
      load_method = RESULT_DATA[field.to_sym]
      return 'term not valid' unless load_method
      default_value = load_method[:default] || []
      load_method[:fields].each do |field|
        field_data += Array.wrap(@item.fetch(field, default_value))
      end
      ApiFieldDataTransformer.transform(field_data: field_data, load_method: load_method[:method])
    end
  end

  class Pager
    def initialize(presenter)
      @presenter = presenter
      @total_results = raw_response.fetch('response').fetch('numFound').to_i
      @start = raw_response.fetch('response').fetch('start').to_i
      @items_per_page = raw_response.fetch('responseHeader').fetch('params').fetch('rows').to_i
      @page = query_parameters.fetch('page', 1).to_i
      @request_url_without_params = File.join(request_url.root.to_s, request_url.path)
    end
    attr_reader :presenter, :total_results, :start, :items_per_page, :page, :request_url_without_params
    delegate :query_parameters, :raw_response, :request_url, to: :presenter

    def next_page
      return nil if last_page?
      page + 1
    end

    def prev_page
      return nil if first_page?
      page - 1
    end

    def last_page?
      total_pages == page
    end

    def total_pages
      return 1 if total_results == 0
      (total_results / items_per_page.to_f).ceil
    end

    def first_page?
      page == 1
    end

    def pagination_url_for(pagination_method)
      case pagination_method
      when :previous
        return false if first_page?
      when :next
        return false if last_page?
      end
      pagination_url = __pagination_url_for(pagination_method)
      yield(pagination_url) if block_given?
      return pagination_url
    end

    private

    def __pagination_url_for(pagination_method)
      case pagination_method
      when :next
        return nil if last_page?
        build_pagination_url(query_parameters.merge('page' => next_page))
      when :previous
        return nil if first_page?
        build_pagination_url(query_parameters.merge('page' => prev_page))
      when :last
        if total_pages == 1
          build_pagination_url(query_parameters.except('page'))
        else
          build_pagination_url(query_parameters.merge('page' => total_pages))
        end
      when :first then
        build_pagination_url(query_parameters.except('page'))
      end
    end

    def build_pagination_url(query_parameters)
      return request_url_without_params if query_parameters.empty?
      "#{request_url_without_params}?#{query_parameters.to_query}"
    end
  end
end

module ApiFieldDataTransformer
  def self.transform(field_data:, load_method:)
    case load_method
    when nil
      return field_data
    when :screen_visibility
      return "public" if field_data.include?("public")
      return "registered" if field_data.include?("registered")
      return "private"
    else
      return field_data.public_send(load_method) if field_data.respond_to?(load_method)
      return field_data
    end
  end
end
