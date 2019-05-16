class Api::ItemsController < CatalogController
  respond_to :jsonld
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier, only: [:show]
  before_filter :validate_permissions!, only: [:show, :download]
  before_filter :item, only: [:show]
  before_filter :set_current_user!, only: [:index]

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
    (@response, @document_list) = get_search_results
    render json: Api::ItemsSearchPresenter.new(@response, request.url, request.query_parameters).to_json
  end

  # GET /api/items/1
  def show
    render json: item.as_jsonld
    # need to define new presenter for new item format, then do:
    # render json: Api::ItemShowPresenter.new(item).to_json
  end

  # GET /api/items/new
  def new
  end

  # GET /api/items/download/1
  def download
    download_noid = Sufia::Noid.noidify(params[:id])
    response.headers['X-Accel-Redirect'] = "/download-content/#{download_noid}"
    head :ok
  end

  # GET /api/items/1/edit
  def edit
  end

  # POST /api/items
  def create
  end

  # PATCH/PUT /api/items/1
  def update
  end

  # DELETE /api/items/1
  def destroy
  end

  private
    def enforce_show_permissions
      # do nothing. This overrides the method used in catalog controller which
      # re-routes show action to a log-in page.
    end

    def item
      @this_item ||= ActiveFedora::Base.find(params[:id], cast: true)
    rescue ActiveFedora::ObjectNotFoundError
      user_name = @current_user.try(:username) || @current_user
      render json: { error: 'Item not found', user: user_name, item: params[:id] }, status: :not_found
    end

    def set_current_user!
      token_sha = request.headers['X-Api-Token']

      if token_sha
        begin
          api_access_token = ApiAccessToken.find(token_sha)
          @current_user = api_access_token.user
        rescue ActiveRecord::RecordNotFound
          @current_user = nil
        end
      else
        @current_user = nil
      end
    end

    def validate_permissions!
      set_current_user!
      item_id = params[:id]
      user_name = @current_user.try(:username) || @current_user
      if current_ability.cannot? :read, item_id
        render json: { error: 'Forbidden', user: user_name, item: item_id }, status: :forbidden
      end
    rescue ActiveFedora::ObjectNotFoundError
      render json: { error: 'Item not found', user: user_name, item: item_id }, status: :not_found
    end

    def build_api_query(solr_parameters, user_parameters)
      # translate API query terms into solr query
      Api::QueryBuilder.new(@current_user).build_filter_queries(solr_parameters, user_parameters)
    end
end

class Api::QueryBuilder
  VALID_KEYS_AND_SEARCH_FIELDNAMES = {
    type: ["active_fedora_model_ssi", "desc_metadata__type_tesim"],
    editor: ["edit_access_person_ssim"],
    depositor: ["depositor_tesim"]
  }.freeze

  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def build_filter_queries(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    VALID_KEYS_AND_SEARCH_FIELDNAMES.keys.each do |key|
      search_elements = Array.wrap(user_parameters[key])
      if !search_elements.empty?
        solr_parameters[:fq] << do_search_for(key, search_elements)
      end
    end
    solr_parameters
  end

  def filter_by_type(term)
    term
  end

  def filter_by_editor(term)
    search_for_user = term
    if term == "self"
      search_for_user = current_user.username
    end
    search_for_user
  end

  def filter_by_depositor(term)
    search_for_user = term
    if term == "self"
      search_for_user = @current_user.username
    end
    search_for_user
  end

  # builds filter query "OR" search for a given key & array of elements
  def do_search_for(key, search_elements)
    filter = ""
    num_elements = search_elements.size
    search_elements.each_with_index do |term, x|
      search_term = self.send("filter_by_#{key}", term)
      filter += (prepare_search_term_for(key, term) + or_if_more(x, num_elements))
    end
    filter
  end

  def or_if_more(x, size)
    text = ""
    if x < size-1 # not last element
      text += " OR "
    end
    text
  end

  def prepare_search_term_for(key, term)
    num_elements = VALID_KEYS_AND_SEARCH_FIELDNAMES[key].size
    search_term = ""
    VALID_KEYS_AND_SEARCH_FIELDNAMES[key].each_with_index do |field, x|
      search_term  += (field + ":" + "\"#{term}\"" + or_if_more(x, num_elements))
    end
    search_term
  end
end
