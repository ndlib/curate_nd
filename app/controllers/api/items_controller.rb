class Api::ItemsController < CommonObjectsController
  # GET /api/items
  def index
  end

  # GET /api/items/1
  def show
    render json: curation_concern.as_jsonld
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

  def enforce_show_permissions
    set_current_user!
    super
  end

  private

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
end
