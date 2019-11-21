class TemporaryAccessTokensController < ApplicationController
  with_themed_layout('1_column')

  before_action :set_temporary_access_token, only: [:show, :edit, :update, :destroy]

  def index
    @limit_to_id ||= limit_to_id
    @limited_item = load_limited_item unless @limit_to_id.nil?
    @temporary_access_tokens = temporary_access_token_list
  end

  def new
    create if params.has_key? :temporary_access_token
    @temporary_access_token = TemporaryAccessToken.new(new_temporary_access_token_params)
  end

  def edit
    @limit_to_id ||= limit_to_id
  end

  def create
    @limit_to_id ||= limit_to_id
    validated_request = TimeLimitedTokenCreateService.new(
      noid: params[:temporary_access_token][:noid],
      issued_by: current_user
    ).make_token
    if validated_request[:valid] == true
      redirect_to temporary_access_tokens_path(limit_to_id: @limit_to_id), notice: validated_request[:notice]
    else
      redirect_to temporary_access_tokens_path(limit_to_id: @limit_to_id), notice: validated_request[:notice]
    end
  end

  def update
    @limit_to_id ||= limit_to_id
    if @temporary_access_token.update(temporary_access_token_params_with_current_user)
      redirect_to temporary_access_tokens_path(limit_to_id: @limit_to_id), notice: 'Temporary access token was successfully renewed.'
    else
      render action: 'edit'
    end
  end

  def revoke_token_access
    @temporary_access_token = TemporaryAccessToken.find(params[:sha])
    @limit_to_id ||= limit_to_id
    @temporary_access_token.revoke!
    redirect_to temporary_access_tokens_path(limit_to_id: @limit_to_id), notice: 'Temporary access token was successfully expired.'
  end

  def destroy
    @limit_to_id ||= limit_to_id
    @temporary_access_token.destroy
    redirect_to temporary_access_tokens_path(limit_to_id: @limit_to_id), notice: 'Temporary access token was successfully deleted.'
  end

  def remove_expired_tokens
    count_destroyed = 0
    if can? :manage, TemporaryAccessToken
      TemporaryAccessToken.find_each do |token|
        if token.obsolete?
          if token.destroy
            count_destroyed += 1
          end
        end
      end
    end
    redirect_to temporary_access_tokens_path, notice: "Number of tokens removed: #{count_destroyed}"
  end

  private

  def set_temporary_access_token
    @temporary_access_token ||= TemporaryAccessToken.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def temporary_access_token_params
    params.require(:temporary_access_token).permit(:noid, :issued_by, :reset_expiry_date, :limit_to_id)
  end

  # Only accept a noid during token creation
  def new_temporary_access_token_params
    if params.has_key? :temporary_access_token
      params.require(:temporary_access_token).permit(:noid, :limit_to_id)
    else
      {}
    end
  end

  # Enforce that the current user is associated with creating or modifying a token
  def temporary_access_token_params_with_current_user
    temporary_access_token_params.merge({ :issued_by => current_user.user_key })
  end

  def temporary_access_token_list
    finding_scope = TemporaryAccessToken.order(updated_at: :desc).page(params[:page])
    finding_scope = finding_scope.where(noid: @limit_to_id) if @limit_to_id.present?
    finding_scope
  end

  def limit_to_id
    if params.has_key? :limit_to_id
      return params[:limit_to_id] unless params[:limit_to_id].empty?
    end
    nil
  end

  def validate_create_token
    item_to_access = begin
      ActiveFedora::Base.load_instance_from_solr(Sufia::Noid.namespaceize(@temporary_access_token.noid))
    rescue ActiveFedora::ObjectNotFoundError
      return { test: :not_found, valid: false, notice: "Unable to create access link: file #{@temporary_access_token.noid} does not exist." }
    end
    # object must be a generic_file
    return { valid: false, notice: "Unable to add access token: item #{@temporary_access_token.noid} is not a file." } unless item_to_access.is_a? GenericFile
    # must be allowed to edit file or token manager
    return { valid: false, notice: "Error: Not authorized to create token for file #{@temporary_access_token.noid}." } unless (can? :edit, item_to_access) || (can? :manage, TemporaryAccessToken)
    # otherwise valid
    { valid: true, notice: nil }
  end

  private

  def load_limited_item
    ActiveFedora::Base.load_instance_from_solr(Sufia::Noid.namespaceize(@limit_to_id))
  end
end
