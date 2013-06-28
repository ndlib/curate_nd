require 'active_fedora/delegate_attributes'

class Person < ActiveFedora::Base
  include ActiveFedora::DelegateAttributes

  has_metadata name: "descMetadata", type: ActiveFedora::QualifiedDublinCoreDatastream do |ds|
    ds.field :display_name, :string
    ds.field :alternate_email, :string
  end

  attribute :display_name,
      datastream: :descMetadata, multiple: false

  attribute :alternate_email,
      datastream: :descMetadata, multiple: false

  def self.find_or_create_by_user(user)
    return Person.find(user.id.to_s)
  rescue ActiveFedora::ObjectNotFoundError
    return create_person(user)
  end

  def self.create_person(user)
    person = Person.new
    person.display_name ||= user.display_name
    person.alternate_email ||= user.email
    person.save!
    person.update_user!(user)
    return person
  end

  def update_user!(user)
    user.update_column(:repository_id, self.pid)
    user.save!
  end
end
