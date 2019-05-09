class Api::ItemsController < ApplicationController
  respond_to :jsonld
  include Sufia::Noid # for normalize_identifier method
  prepend_before_filter :normalize_identifier
  before_filter :validate_permissions!
  before_filter :item, only: [:show]

  # GET /api/items
  def index
  end

  # GET /api/items/1
  def show
    render json: item.as_jsonld
  end

  # GET /api/items/new
  def new
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

  def dismiss
  end

  private

    def item
      @this_item ||= ActiveFedora::Base.find(params[:id], cast: true)
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
    end
end
