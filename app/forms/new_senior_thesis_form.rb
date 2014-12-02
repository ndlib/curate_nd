class NewSeniorThesisForm
  include ActiveModel::Validations
  extend ActiveModel::Translation

  attr_reader :model, :attributes
  def initialize(attributes = {})
    @model = attributes.fetch(:model) { SeniorThesis.new }
    @attributes = HashWithIndifferentAccess.new
    attributes.each do |key, value|
      if respond_to?("#{key}=")
        public_send("#{key}=", value)
        @attributes[key] = value unless key.to_s == 'accept_contributor_agreement'
      end
    end
  end

  def self.model_name
    SeniorThesis.model_name
  end

  delegate :to_key, :to_param, :persisted?, :human_readable_type, :registered_remote_identifier_minters, to: :model

  attr_accessor :title, :description, :date_created, :creator, :rights,
    :embargo_release_date, :identifier, :doi_assignment_strategy,
    :existing_identifier, :advisor, :contributor, :subject,
    :bibliographic_citation, :language, :publisher, :type_of_license, :license,
    :accept_contributor_agreement, :files, :visibility

  validates :title, presence: true
  validates :date_created, presence: true
  validates :creator, presence: true
  validates :description, presence: true
  validates :rights, presence: true
  validates :visibility, presence: true
  validates :accept_contributor_agreement, inclusion: %w(1 true yes)

  # @return false if the form was not valid
  # @return true if the form was valid and the caller's submission block was
  #   successful
  # @yield [VirtualForm] when the form is valid yield control to the caller
  # @yieldparam form [VirtualForm]
  # @yieldreturn the sender's response successful
  def submit
    return false unless valid?
    return yield(self)
  end

  def open_access?
    false
  end

  def open_access_with_embargo_release_date?
    false
  end

  def authenticated_only_access?
    false
  end

  def private_access?
    false
  end

end
