# Responsible for generating the JSON search results from a Blacklight search response
# (based on catalog_index_jsonld_presenter)
class Api::ItemsSearchPresenter
  include Sufia::Noid
  attr_reader :raw_response, :request_url, :documents, :pager, :query_parameters

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
        params: query_parameters
      ).content
      json['results'] << document_object
    end
  end

  class SingleItemResult
    # item: a single Solr document
    # fields: list of additional fields to include from query parameters
    def initialize(item:, params:)
      @item = item
      @params = params
      @fields = (params[:fl].nil? ? nil : params[:fl].split(","))
    end

    attr_reader :item, :fields, :params

    def content
      # always include standard list of fields
      results_hash = {
        "id" => item_id,
        "title" => dc_title,
        "type" => dc_type,
        "itemUrl" => File.join(Rails.configuration.application_root_url,  Rails.application.routes.url_helpers.api_item_path(item_id))
      }
      # always include any fields which were part of query.
      results_hash = results_hash.merge(load_query_fields)
      # return any additional requested fields
      if !fields.nil?
        fields.each do |field|
          results_hash[field] = self.send("include_#{field}")
        end
      end
      results_hash
    end

    def load_query_fields
      hash = {}
      params.keys.each do |key|
        fields = Api::QueryBuilder::VALID_KEYS_AND_SEARCH_FIELDNAMES[key.to_sym]
        if fields.present?
          fields.each do |field|
            value = @item.fetch(field, [])
            hash[key] = value unless value.empty?
          end
        end
      end
      hash
    end

    def item_id
      @item_id ||= Sufia::Noid.noidify(@item.fetch('id'))
    end

    def dc_title
      dc_title = Array.wrap(@item.fetch('desc_metadata__title_tesim', 'title-not-found' )).first
    end

    def dc_type
      model = Array.wrap(@item.fetch('active_fedora_model_ssi'))
      dc_type = @item.fetch('desc_metadata__type_tesim', model)
      Array.wrap(dc_type).first
    end

    def include_language
      @item.fetch('desc_metadata__language_tesim', []).first
    end

    def include_creator
      @item.fetch('desc_metadata__creator_tesim', []).first
    end

    def include_depositor
      @item.fetch('depositor_tesim', []).first
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
