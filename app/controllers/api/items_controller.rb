require 'aws-sdk-s3'
require 'json'

class Api::ItemsController < CatalogController
  respond_to :jsonld
  include Sufia::Noid # for normalize_identifier method
  include Sufia::IdService # for mint method
  prepend_before_filter :normalize_identifier, only: [:show, :download]
  before_filter :validate_permissions!, only: [:show, :download]
  before_filter :item, only: [:show]
  before_filter :set_current_user!, only: [:index, :trx_initiate, :trx_new_file]

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
    render json: Api::ShowItemPresenter.new(item, request.url).to_json
  end

  # GET /api/items/download/1
  def download
    request_noid = Sufia::Noid.noidify(params[:id])
    download_noids = find_download_noids
    case download_noids.count
    when 0
      render json: { error: 'No authorized content' }, status: :expectation_failed
    when 1
      response.headers['X-Accel-Redirect'] = "/download-content/#{download_noids.first}"
      head :ok
    else
      response.headers['X-Accel-Redirect'] = "/download-content/#{request_noid}/zip/#{download_noids.join(',')}"
      head :ok
    end
  end

  # GET /api/upload/new
  def trx_initiate
    if @current_user
      trx_id = ApiTransaction.new_trx_id
      start_transaction = ApiTransaction.new(trx_id: trx_id, user_id: @current_user.id, trx_status: ApiTransaction.set_status(:new))
    end
    if @current_user && start_transaction.save
      render json: { trx_id: trx_id }, status: :ok
    else
      render json: { error: 'Transaction not initiated' }, status: :expectation_failed
    end
  end

  # POST /api/uploads/:tid/file/new
  # Start a new upload of a file associated with this transaction
  def trx_new_file
    if @current_user
      #parse out trx_id
      trx_id = params[:tid]

      #parse out file_name
      file_name = request.query_parameters[:file_name]
      #get a pid for the file
      file_pid = Sufia::Noid.noidify(Sufia::IdService.mint)
      # s3 bucket connection
      s3 = Aws::S3::Resource.new(region:'us-east-1')
      content = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/#{file_pid}-001")
      #copy body of message to bucket
      content.put(body: request.body())
      metadata = s3.bucket(ENV['S3_BUCKET']).object("#{trx_id}/metadata-#{file_pid}.json")
      metadata.put(body: initial_file_metadata(file_name, file_pid))
      render json: { trx_id: trx_id, file_name: file_name, file_pid: file_pid, s3_bucket: ENV['S3_BUCKET'] }, status: :ok
    end
  end

  def trx_append
      render json: { error: 'Method trx_append not implemented' }, status: :ok
  end

  def trx_commit
      render json: { error: 'Method trx_commit not implemented' }, status: :ok
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

    def find_download_noids
      solr_query_string = ActiveFedora::SolrService.construct_query_for_pids([params[:id]])
      solr_results = ActiveFedora::SolrService.query(solr_query_string)
      this_item = ActiveFedora::SolrService.reify_solr_results(solr_results).first
      # if item is a file, we have already validated authority, so just return noid
      return [Sufia::Noid.noidify(params[:id])] if this_item.is_a?(GenericFile)
      # if item is a work, we need to find all the generic files and check authority
      authorized_file_noids = []
      this_item.generic_files.each do |file|
        authorized_file_noids << Sufia::Noid.noidify(file.id) if @current_user.can? :read, file
      end
      authorized_file_noids
    end

    def build_api_query(solr_parameters, user_parameters)
      # translate API query terms into solr query
      Api::QueryBuilder.new(@current_user).build_filter_queries(solr_parameters, user_parameters)
    end

    def initial_file_metadata(file_name, file_pid)
      metadata_hash = {}
      metadata_hash[:pid] = "und:#{file_pid}"
      metadata_hash[:content_meta] = {}
      metadata_hash[:metadata] = {}
      metadata_hash[:content_meta][:label] = "#{file_name}"
      metadata_hash[:metadata]['dc:title'] = "#{file_name}"
      JSON.dump(metadata_hash)
    end
end
