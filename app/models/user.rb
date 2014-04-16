class User < ActiveRecord::Base

  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Connects this user object to Sufia behaviors.
  include Sufia::User

  include Curate::UserBehavior

  def self.search(query = nil)
    if query.to_s.strip.present?
      term = "#{query.to_s.upcase}%"
      where("UPPER(email) LIKE :term OR UPPER(display_name) LIKE :term OR UPPER(username) LIKE :term", {term: term})
    else
      all
    end.order(:username)
  end

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :masqueradable

  attr_accessor :password

  def password_required?; false; end
  def email_required?; false; end

  def update_with_password(attributes)
    self.update(attributes)
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

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    username
  end

  def to_param
    id
  end

  protected

  def ldap_service
    @ldap ||= LdapService.new(self)
  end

end
