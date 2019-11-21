class TimeLimitedTokenCreateService
  # TimeLimitedTokenService.new(noid: "0r96736668t", user: User.third).make_token
  attr_reader :noid, :user

  # @param noid [String] the noid of a GenericFile
  # @param issued_by [User] the user issuing the token
  def initialize(noid:, issued_by:)
    @noid = noid
    @user = issued_by
  end

  # @return [Hash] {:test, :valid, :notice, :token}
  def make_token
    validated_request = validate_request
    if validated_request[:valid]
      token = create_token
      if token
        validated_request[:notice] = "Temporary access token was successfully created."
        validated_request[:token] = token
      end
    end
    validated_request
  end

  # @param noid [String] the noid of a GenericFile
  # @param user [User] the user adding the token
  # @return [Hash] {:test, :valid, :notice}
  def validate_request
    item_to_access = begin
      ActiveFedora::Base.load_instance_from_solr(Sufia::Noid.namespaceize(@noid))
    rescue ActiveFedora::ObjectNotFoundError
      nil
    end

    # object must exist
    return { test: :not_found,
             valid: false,
             notice: "Unable to create temporary access token: file '#{@noid}' does not exist."
            } unless item_to_access

    # must be given a user
    return { test: :no_user,
             valid: false,
             notice: "Unable to create temporary access token without a user."
            } unless @user

    # object must be a generic_file
    return { test: :not_file,
             valid: false,
             notice: "Unable to create temporary access token: item '#{@noid}' is not a file."
            } unless item_to_access.is_a? GenericFile

    # must be allowed to edit file or token manager
    return { test: :not_authorized,
             valid: false,
             notice: "Error: Not authorized to create temporary access token for file '#{@noid}."
            } unless (@user.can? :edit, item_to_access) || (@user.can? :manage, TemporaryAccessToken)

    # otherwise valid
    { test: :passed,
      valid: true,
      notice: nil }
  end

  def create_token
    token = TemporaryAccessToken.new(noid: @noid, issued_by: @user.user_key)
    if token.save
      return token
    end
    false
  end
end
