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
  attr_accessible :email, :remember_me, :username, :name, :alternate_email, :preferred_email

  attr_accessor :password

  after_create :find_or_create_person
  after_update :update_person
  
  GRAVATAR_URL = "http://www.gravatar.com/avatar/"

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
    @display_name ||= self.attributes['display_name'] || person.display_name || ldap_service.display_name
  end

  def display_name=(display_name)
    write_attribute(:display_name, display_name)
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

  # Two parameters in the link
  # 's' stands for size & 'd' stands for default link
  # If user has not registered both their email IDs with gravatar, it will default to gravatar image.
  def gravatar_link
    return @gravatar_link unless @gravatar_link.blank?
    @gravatar_link = File.join(GRAVATAR_URL, email_hash(self.preferred_email), "?s=200")
    @gravatar_link += "&d=" + File.join(GRAVATAR_URL, email_hash(self.alternate_email), "?s=200") unless self.alternate_email.blank?
    @gravatar_link
  end

  alias_method :name, :display_name
  alias_method :name=, :display_name=

  protected

  def ldap_service
    @ldap ||= LdapService.new(self)
  end

  def update_person
    person.save
  end

  def email_hash(gravatar_email)
    @md5 = Digest::MD5.hexdigest(gravatar_email.to_s.strip.downcase)
  end
end
