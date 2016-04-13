# Not all work types can be created by all users. This policy object answers
# whether a user is authorized to create a given work type.
#
# Rules are defined in config/work_type_policy_rules.yml
class WorkTypePolicy
  attr_accessor :user, :permission_rules

  def initialize( user: current_user, permission_rules: WORK_TYPE_POLICY_RULES )
    self.user = user
    self.permission_rules = permission_rules
  end

  def authorized_for?( work_type )
    rules = rules_for( work_type )
    case rules
    when 'all' then true
    when 'nobody' then false
    else user_has_privileged_group?( rules )
    end
  end

  private

  def rules_for(work_type)
    return false unless permission_rules.has_key?( work_type )
    work_type_rules = permission_rules.fetch( work_type )
    return false if work_type_rules.blank?
    work_type_rules.fetch( 'open' ) { 'nobody' }
  end

  def user_groups
    @user_groups ||= user.groups
  end

  def user_has_privileged_group?( group_keys )
    privileged_groups = Array.wrap( group_keys )
    users_privileged_groups = user_groups & privileged_groups
    users_privileged_groups.any?
  end
end
