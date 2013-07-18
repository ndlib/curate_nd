require 'active_fedora/registered_attributes'

class Person < ActiveFedora::Base
  include ActiveFedora::RegisteredAttributes

  has_metadata name: "descMetadata", type: ActiveFedora::QualifiedDublinCoreDatastream do |ds|
    ds.field :display_name, :string
    ds.field :preferred_email, :string
    ds.field :alternate_email, :string
  end

  attribute :display_name,
      datastream: :descMetadata, multiple: false

  attribute :preferred_email,
      datastream: :descMetadata, multiple: false

  attribute :alternate_email,
      datastream: :descMetadata, multiple: false

  def self.find_or_create_by_user(user)
    return Person.find(user.repository_id.to_s)
  rescue ActiveFedora::ObjectNotFoundError, ArgumentError
    return create_person(user)
  end

  def self.create_person(user)
    person = Person.new
    person.display_name = user.get_value_from_ldap(:display_name)
    person.preferred_email = user.get_value_from_ldap(:preferred_email)
    person.alternate_email = user.email
    person.save!
    person.update_user!(user)
    person
  end

  def update_user!(user)
    user.update_column(:repository_id, self.pid)
  end
end
