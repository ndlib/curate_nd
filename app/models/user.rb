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

  person_attribute_readers = [:title, :campus_phone_number, :alternate_phone_number, :personal_webpage, :date_of_birth, :gender, :blog]
  person_attribute_setters =  person_attribute_readers.collect{|method_name| "#{method_name}=".to_sym}

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :username, :name, :preferred_email, :alternate_email, *person_attribute_readers

  attr_accessor :password

  # Every User has an associated Person record in Fedora, which is created lazily.
  after_commit :update_person

  delegate :first_name, :last_name, *person_attribute_readers, *person_attribute_setters, to: :person

  GRAVATAR_URL = "http://www.gravatar.com/avatar/"

  def password_required?; false; end
  def email_required?; false; end

  def preferred_email
    if person.preferred_email.blank?
      return ldap_service.preferred_email
    end
    person.preferred_email
  end

  def preferred_email=(preferred_email)
    person.preferred_email = preferred_email
  end

  # is this what is really desired? to return the email if the alternate email is blank?
  def alternate_email
    if person.alternate_email.blank?
      return email
    end
    person.alternate_email
  end

  def alternate_email=(alternate_email)
    person.alternate_email = alternate_email
  end

  def display_name
    @display_name ||= self.attributes['display_name'] || person.name || ldap_service.display_name
  end

  def display_name=(display_name)
    write_attribute(:display_name, display_name)
    person.name= display_name
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
    @person ||= if self.repository_id
                  Person.find(self.repository_id)
                else
                  create_person
                end
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

  # Make a new person object and populate it.
  # Must be careful since when we update ourselves with a link to the new
  # person object, we will trigger a callback to save the person
  # object (again).
  def create_person
    person = Person.new
    person.name = get_value_from_ldap(:display_name)
    person.preferred_email = get_value_from_ldap(:preferred_email)
    person.alternate_email = email
    person.save!
    self.repository_id = person.pid
    self.save
    person
  end

  def update_person
    person.save
  end

  def email_hash(gravatar_email)
    Digest::MD5.hexdigest(gravatar_email.to_s.strip.downcase)
  end
end
