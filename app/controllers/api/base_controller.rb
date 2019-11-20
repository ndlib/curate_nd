class Api::BaseController < CatalogController
  respond_to :jsonld
  include Sufia::Noid # for normalize_identifier method to add 'und:' prefix

  private
    def enforce_show_permissions
      # do nothing. This overrides the method used in catalog controller which
      # re-routes show action to a log-in page.
    end

    def set_current_user!
      @current_user = nil
      token_sha = request.headers['X-Api-Token']

      if token_sha
        api_access_token = find_token(token_sha)
        if api_access_token
          @current_user = api_access_token.user
        end
      end
      @current_user
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

    def find_token(token_sha)
      begin
        ApiAccessToken.find(token_sha)
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end
end
