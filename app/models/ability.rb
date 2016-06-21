# Ability defines the authorization logic used by cancan
class Ability
  include Hydra::Ability

  self.ability_logic += [:curate_permissions, :collection_permissions, :licensing_permissions]

  # Note: custom_permissions are assumed to injected into the process as well.
  def custom_permissions
    @user_work_type_policy ||= WorkTypePolicy.new(user: current_user)

    Curate.configuration.registered_curation_concern_types.each do |work_type|
      # Blacklisting Create for work types UNLESS explicitly authorized
      unless @user_work_type_policy.authorized_for?(work_type)
        # Show, Edit, Update, and Destroy are determined by the access controls
        # on the work.
        cannot :create, work_type.constantize
      end

      # Access to ETD-specific functions is limited to names in etd_manager_permission.yml
      unless EtdManagers.include?(current_user)
        cannot [:manage], EtdVocabulary
        cannot [:manage], TemporaryAccessToken
      end
    end
  end

  def curate_permissions
    alias_action :confirm, :copy, :to => :update
    if current_user.manager?
      can [:discover, :show, :read, :edit, :update, :destroy], :all
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
    logger.debug("[CANCAN] Checking read permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")

    # Get the user's groups
    group_intersection = user_groups & read_groups(fedora_object.pid)

    # Don't use public and registered groups when enforcing embargo
    embargo_group_intersection = group_intersection - ["public", "registered"]

    # Under embargo and the current user has read permissions
    if fedora_object.respond_to?(:under_embargo?) && fedora_object.under_embargo? && (read_persons(fedora_object.pid).include?(current_user.user_key) || !embargo_group_intersection.empty?)
      result = true

    # Under embargo and the current user doesn't have read permissions
    elsif fedora_object.respond_to?(:under_embargo?) && fedora_object.under_embargo? && (!read_persons(fedora_object.pid).include?(current_user.user_key) && embargo_group_intersection.empty?)
      result = false

    # Not under embargo, using the default hydra-acess-controls check
    else
      result = !group_intersection.empty? || read_persons(fedora_object.pid).include?(current_user.user_key)
    end

    logger.debug("[CANCAN] decision: #{result}")
    result
  end

  # Need a custom method to enforce embargo when a Fedora object is input, like on the CanCan authorize checks.
  def test_edit_fedora_object(fedora_object)
    logger.debug("[CANCAN] Checking edit permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")

    # Get the user's groups
    group_intersection = user_groups & edit_groups(fedora_object.pid)

    # Don't use public and registered groups when enforcing embargo
    embargo_group_intersection = group_intersection - ["public", "registered"]

    # Under embargo and the current user has edit permissions
    if fedora_object.respond_to?(:under_embargo?) && fedora_object.under_embargo? && (edit_persons(fedora_object.pid).include?(current_user.user_key) || !embargo_group_intersection.empty?)
      result = true

    # Under embargo and the current user doesn't have edit permissions
    elsif fedora_object.respond_to?(:under_embargo?) && fedora_object.under_embargo? && (!edit_persons(fedora_object.pid).include?(current_user.user_key) && embargo_group_intersection.empty?)
      result = false

    # Not under embargo, using the default hydra-acess-controls check
    else
      result = !group_intersection.empty? || edit_persons(fedora_object.pid).include?(current_user.user_key)
    end

    logger.debug("[CANCAN] decision: #{result}")
    result
  end

  # Copied this method hydra-access-controls ability.rb#test_read. Embargo is already enforced on Solr search so it's not enforced here.
  def test_read_solr(pid)
    logger.debug("[CANCAN] Checking read permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
    group_intersection = user_groups & read_groups(pid)
    result = !group_intersection.empty? || read_persons(pid).include?(current_user.user_key)
    result
  end

  # Copied this method hydra-access-controls ability.rb#test_edit. Embargo is already enforced on Solr search so it's not enforced here.
  def test_edit_solr(pid)
    logger.debug("[CANCAN] Checking edit permissions for user: #{current_user.user_key} with groups: #{user_groups.inspect}")
    group_intersection = user_groups & edit_groups(pid)
    result = !group_intersection.empty? || edit_persons(pid).include?(current_user.user_key)
    logger.debug("[CANCAN] decision: #{result}")
    result
  end

end
