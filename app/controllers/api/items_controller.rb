class Api::ItemsController < Api::BaseController
  prepend_before_filter :normalize_identifier, only: [:show, :token]
  before_filter :validate_permissions!, only: [:show]
  before_filter :item, only: [:show]
  before_filter :set_current_user!, only: [:index, :token]

  self.solr_search_params_logic = [
    :default_solr_parameters,
    :add_query_to_solr,
    :add_paging_to_solr,
    :add_sorting_to_solr,
    :add_access_controls_to_solr_params,
    :enforce_embargo,
    :exclude_unwanted_models,
    :build_api_query
  ]

  # GET /api/items
  def index
    if valid_search_request_syntax?
      (@response, @document_list) = get_search_results
      response_data = Api::ItemsSearchPresenter.new(@response, request.url, request.query_parameters)
      respond_to do |format|
        format.xml { render xml: response_data.to_xml }
        format.json { render json: response_data.to_json }
      end
    else
      error_data = { error: 'Invalid search request format. Please consult API documentation.' }
      respond_to do |format|
        format.xml { render xml: error_data.to_xml, status: :bad_request }
        format.json { render json: error_data.to_json, status: :bad_request }
      end
    end
  end

  # GET /api/items/1
  def show
    show_data = Api::ShowItemPresenter.new(item, request.url, request.format)
    respond_to do |format|
      format.xml {render xml: show_data.to_xml }
      format.json { render json: show_data.to_json }
    end
  end

  # POST /api/items/1/token
  def token
    validated_request= TimeLimitedTokenCreateService.new(noid: params[:id], issued_by: @current_user).make_token
    if validated_request[:valid] == true
      render json: { notice: validated_request[:notice], access_url: File.join(download_url, "?token=#{validated_request[:token][:sha]}") }, status: :ok
    else
      render json: { error: validated_request[:notice] }, status: :bad_request
    end
  end

  private

    def valid_search_request_syntax?
      Api::QueryBuilder.new(@current_user).valid_request?(params)
    end

    def item
      @this_item ||= ActiveFedora::Base.find(params[:id], cast: true)
    rescue ActiveFedora::ObjectNotFoundError
      user_name = @current_user.try(:username) || @current_user
      render json: { error: 'Item not found', user: user_name, item: params[:id] }, status: :not_found
    end

    def build_api_query(solr_parameters, user_parameters)
      # translate API query terms into solr query using API::QueryBuilder service
      Api::QueryBuilder.new(@current_user).build_filter_queries(solr_parameters, user_parameters)
    end
end
