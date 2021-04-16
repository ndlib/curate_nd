# Ability defines the authorization logic used by cancan
class Ability
  include Hydra::Ability

  self.ability_logic += [:curate_permissions, :collection_permissions, :licensing_permissions, :api_token_permissions]

  # Note: custom_permissions are assumed to injected into the process as well.
  def custom_permissions
    Curate.configuration.registered_curation_concern_types.each do |work_type|
      # Blacklisting Create for work types UNLESS explicitly authorized
      unless user_work_type_policy.authorized_for?(work_type)
        # Show, Edit, Update, and Destroy are determined by the access controls
        # on the work.
        cannot :create, work_type.constantize
      end

      # Access to temporary access token management is limited to names in etd_manager_permission.yml
      if token_managers.include?(current_user.to_s)
        can [:manage], TemporaryAccessToken
      else
        cannot [:manage], TemporaryAccessToken
      end

      if super_administrators.include?(current_user.to_s)
        can [:manage], Admin::AuthorityGroup
        can [:orphan], GenericFile
      else
        cannot [:manage], Admin::AuthorityGroup
        cannot [:orphan], GenericFile
      end

      if repository_administrators.include?(current_user.to_s)
        can :characterize_file, :all
      else
        cannot :characterize_file, :all
      end
    end
  end

  # Load permission objects
  def user_work_type_policy
    @user_work_type_policy ||= WorkTypePolicy.new(user: current_user)
  end

  def token_managers
    @token_managers ||= Admin::AuthorityGroup::TokenManager.new.usernames
  end

  def super_administrators
    @super_administrators ||= Admin::AuthorityGroup::SuperAdmin.new.usernames
  end

  def repository_administrators
    @repository_administrators ||= Admin::AuthorityGroup::RepositoryAdministrator.new.usernames
  end

  def view_all_works
    @view_all_works ||= Admin::AuthorityGroup::ViewAll.new.usernames
  end
  # end Load permission objects

  def curate_permissions
    alias_action :confirm, :copy, :to => :update
    if current_user.manager?
      can [:discover, :show, :read, :edit, :update, :destroy], :all
    else
      if  view_all_works.include?(current_user.to_s)
        can [:discover, :show, :read], :all
      end
    end

    can [:read, :show], LibraryCollection
    # This is a concession concerning the UI; LibraryCollections are made
    # via the batch ingest.
    cannot [:edit, :update, :destroy, :create], LibraryCollection

    can :edit, Person do |p|
      p.pid == current_user.repository_id
    end

    can [:show, :read, :update, :destroy], [Curate.configuration.curation_concerns] do |w|
      u = ::User.find_by_user_key(w.owner)
      u && u.can_receive_deposits_from.include?(current_user)
    end
  end

  def licensing_permissions(licensing_permission = ContentLicense.new(current_user))
    if licensing_permission.is_permitted?
      can :edit, ContentLicense
    else
      cannot :edit, ContentLicense
    end
  end

  def collection_permissions
    can :collect, :all
  end

  def api_token_permissions
    if CurateND::AdminConstraint.is_admin?(current_user)
      can [:manage], ApiAccessToken
    else
      cannot [:manage], ApiAccessToken
    end
  end

  # Overriding hydra-access-controls in order to enforce embargo
  def edit_permissions
    can [:edit, :update, :destroy], String do |pid|
      test_edit(pid)
    end

    can [:edit, :update, :destroy], ActiveFedora::Base do |obj|
      test_edit(obj)
    end

    can :edit, SolrDocument do |obj|
      cache.put(obj.id, obj)
      test_edit(obj.id)
    end
  end

  # Overriding hydra-access-controls in order to enforce embargo
  def read_permissions
    can :read, String do |pid|
      test_read(pid)
    end

    # Had to add obj to params because test_read needs to check embargo
    can :read, ActiveFedora::Base do |obj|
      test_read(obj)
    end

    can :read, SolrDocument do |obj|
      cache.put(obj.id, obj)
      test_read(obj.id)
    end
  end

  def test_read(obj)
    if obj.is_a? ActiveFedora::Base
      test_read_fedora_object(obj)
    else
      test_read_solr(obj)
    end
  end

  def test_edit(obj)
    if obj.is_a? ActiveFedora::Base
      test_edit_fedora_object(obj)
    else
      test_read_solr(obj)
    end
  end

  # Need a custom method to enforce embargo when a Fedora object is input, like on the CanCan authorize checks.
  def test_read_fedora_object(fedora_object)
    test_reified_object_with_method(fedora_object, method: :read)
  end

  # Need a custom method to enforce embargo when a Fedora object is input, like on the CanCan authorize checks.
  def test_edit_fedora_object(fedora_object)
    test_reified_object_with_method(fedora_object, method: :edit)
  end

  # Test reading an object; There were claims in the previous comment that Solr was already enforcing the embargo, but that was not the
  # case in workign through downloads logic.
  def test_read_solr(pid)
    object = ActiveFedora::Base.load_instance_from_solr(pid)
    test_reified_object_with_method(object, method: :read)
  end

  # Test reading an object; There were claims in the previous comment that Solr was already enforcing the embargo, but that was not the
  # case in workign through downloads logic.
  def test_edit_solr(pid)
    object = ActiveFedora::Base.load_instance_from_solr(pid)
    test_reified_object_with_method(object, method: :edit)
  end

  # There was a tremendous amount of duplication between two methods; It was going to be four methods prior to this refactor.
  def test_reified_object_with_method(fedora_like_object, method: :read)
    logger.debug("[CANCAN] Checking #{method} permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")

    # Get the user's groups
    group_intersection = user_groups & send("#{method}_groups", fedora_like_object.pid)

    # Don't use public and registered groups when enforcing embargo
    embargo_group_intersection = group_intersection - ["public", "registered"]

    is_object_under_embargo = fedora_like_object.respond_to?(:under_embargo?) && fedora_like_object.under_embargo?

    # Under embargo and the current user has read permissions
    if is_object_under_embargo && (send("#{method}_persons", fedora_like_object.pid).include?(current_user.user_key) || !embargo_group_intersection.empty?)
      result = true

    # Under embargo and the current user doesn't have read permissions
    elsif is_object_under_embargo && (!send("#{method}_persons", fedora_like_object.pid).include?(current_user.user_key) && embargo_group_intersection.empty?)
      result = false

    # Not under embargo, using the default hydra-acess-controls check
    else
      result = !group_intersection.empty? || send("#{method}_persons", fedora_like_object.pid).include?(current_user.user_key)
    end

    logger.debug("[CANCAN] decision: #{result}")
    result
  end
end
