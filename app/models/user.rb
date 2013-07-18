class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Connects this user object to Sufia behaviors.
  include Sufia::User

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :username, :alternate_email, :preferred_email

  attr_accessor :password

  after_create :find_or_create_person
  after_update :update_person
  
  def password_required?; false; end
  def email_required?; false; end

  def preferred_email
    if person.blank? || person.preferred_email.blank?
      return ldap_service.preferred_email
    end
    person.preferred_email
  end

  def preferred_email=(preferred_email)
    person.preferred_email= preferred_email
  end

  def alternate_email
    if person.blank? || person.alternate_email.blank?
      return email
    end
    person.alternate_email
  end

  def alternate_email=(alternate_email)
    person.alternate_email = alternate_email
  end

  def display_name
    if person.blank? || person.display_name.blank?
      return ldap_service.display_name
    end
    person.display_name
  end

  def display_name=(display_name)
    person.display_name= display_name
  end

  def update_with_password(attributes)
    self.email = attributes[:email]
    self.save
  end

  def self.audituser
    User.find_by_user_key(audituser_key) || User.create!(Devise.authentication_keys.first => audituser_key)
  end

  def self.audituser_key
    'curate_nd_audituser'
  end

  def self.batchuser
    User.find_by_user_key(batchuser_key) || User.create!(Devise.authentication_keys.first => batchuser_key)
  end

  def self.batchuser_key
    'curate_nd_batchuser'
  end

  def agree_to_terms_of_service!
    update_column(:agreed_to_terms_of_service, true)
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    username
  end

  def to_param
    id
  end
  
  def person
    @person ||= Person.find(self.repository_id)
  rescue ArgumentError
    nil
  end

  def find_or_create_person
    @person = Person.find_or_create_by_user(self)
  end

  def get_value_from_ldap(attr)
    ldap_service.send(attr.to_sym)
  end

  protected

  def ldap_service
    @ldap ||= LdapService.new(self)
  end

  def update_person
    person.save
  end
end
