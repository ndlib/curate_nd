module Api
  class AppUsersController < ApplicationController
    with_themed_layout '1_column'
    before_filter :validate_permissions!
  # permits creation of basic user for api data access equal to registered access

    # GET /api/app_users/new
    def new
    end

    def create
      api_user = (params.has_key?(:new_api_user) ?  params.fetch(:new_api_user) : nil)
      if api_user
        if user_exists?(username: api_user[:user_name])
          redirect_to api_app_users_new_path, notice: "Username #{api_user[:user_name]} already exists"
        else
          create_app_user(username: api_user[:user_name], name: api_user[:application])
          redirect_to new_api_access_token_path, notice: "User #{api_user[:user_name]} has been created"
        end
      else
        redirect_to new_api_access_token_path, notice: "Cannot create API app user"
      end
    end

    private

    # validate unique user before proceeding
    def user_exists?(username:)
      return true if User.find_by(username: username)
      false
    end

    # Creates a new user without duplicating usernames
    def create_app_user(username:, name:)
      user = User.find_or_create_by(username: name) do |u|
        u.username = username
        u.name = name
      end
      user
    end

    def validate_permissions!
      if current_ability.cannot? :manage, ApiAccessToken
        redirect_to new_api_access_token_path, notice: 'Not authorized to create an API app user'
      end
    end
  end
end
