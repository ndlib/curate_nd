module Api
  class AccessTokensController < ApplicationController
    with_themed_layout '1_column'

    before_action :set_api_access_token, only: [:destroy]

    # GET /api/access_tokens
    def index
      @api_access_tokens = api_access_token_list
    end

    # GET /api/access_tokens/new
    def new
      @api_access_token = ApiAccessToken.new
    end

    # POST /api/access_tokens
    def create

      @api_access_token = ApiAccessToken.new(api_access_token_params_with_user)

      if @api_access_token.save
        redirect_to api_access_tokens_path, notice: 'Api access token was successfully created.'
      else
        render :new
      end
    end

    # DELETE /api/access_tokens/1
    def destroy
      @api_access_token.destroy
      redirect_to api_access_tokens_url, notice: 'Api access token was successfully destroyed.'
    end

    private

      def api_access_token_list
        @api_access_tokens =
        begin
          if can? :manage, ApiAccessToken
            @api_access_tokens = ApiAccessToken.all
          else
            @api_access_tokens = ApiAccessToken.where(issued_by: current_user.username)
          end
        end.page(params[:page])
      end

      def set_api_access_token
        @api_access_token = ApiAccessToken.find(params[:id])
      end

      def api_access_token_params
        params.require(:api_access_token).permit(:user_id)
      end

      def api_access_token_params_with_user
        api_access_token_params.merge({ :issued_by => current_user.user_key })
      end
  end
end
