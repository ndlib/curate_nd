class Api::BaseController < CatalogController
  respond_to :jsonld
  include Sufia::Noid # for normalize_identifier method to add 'und:' prefix

  private
    def enforce_show_permissions
      # do nothing. This overrides the method used in catalog controller which
      # re-routes show action to a log-in page.
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
end
