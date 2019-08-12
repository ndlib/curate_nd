class TemporaryAccessToken < ActiveRecord::Base
  self.primary_key = 'sha'
  paginates_per 15

  def self.hours_until_expiry
    24
  end

  def self.permitted?(noid, sha)
    valid_tokens(noid, sha).any?
  end

  def self.use!(sha)
    tokens = self.where(sha: sha)
    updated_tokens  = []

    tokens.each do |token|
      if token.expiry_date.blank?
        token.update_attribute(:expiry_date, new_expiry_date)
        updated_tokens << token
      end
    end

    updated_tokens.any?
  end

  def self.valid_tokens(noid, sha)
    self.where(noid: noid, sha: sha).where("#{self.quoted_table_name}.`expiry_date` IS NULL OR #{self.quoted_table_name}.`expiry_date` >= ?", Time.now)
  end
  private_class_method :valid_tokens

  def self.new_expiry_date
    Time.now + hours_until_expiry.hours
  end
  private_class_method :new_expiry_date

  validates_presence_of :noid, :issued_by
  validates_uniqueness_of :sha
  before_create :assign_new_sha, :strip_pid_namespace
  before_update :reset_expiry_date_if_prompted
  attr_accessor :reset_expiry_date

  def assign_new_sha
    assign_attributes(sha: generate_sha)
  end
  private :assign_new_sha

  def generate_sha
    SecureRandom.urlsafe_base64(32, false)
  end
  private :generate_sha

  def reset_expiry_date_if_prompted
    if reset_expiry_date
      self.expiry_date = nil
    end
  end
  private :reset_expiry_date_if_prompted

  def strip_pid_namespace
    assign_attributes(noid: Sufia::Noid.noidify(noid))
  end
  private :strip_pid_namespace

  def obsolete?
    if expiry_date.nil?
      # obsolete if never used and not modified in last 90 days
      return updated_at < Date.today - 90
    else
      # obsolete if past expiry_date
      return expiry_date < Date.today
    end
  end

  def revoke!
    update_attribute(:expiry_date, Time.now)
  end

  def user_is_editor(user)
    return false if user.nil?
    begin
      return user.can? :edit, Sufia::Noid.namespaceize(noid)
    rescue ActiveFedora::ObjectNotFoundError
      return false
    end
  end

  # Prepare error info for access denied w/ token
  def self.access_request_allowed_for?(token_sha)
    token = load_token(token_sha)
    return false if token.this_request.nil?
    return false if token.request_recipient.nil?
    return true
  end

  def self.load_token(token_sha)
    self.find(token_sha)
  end
  private_class_method :load_token

  def self.build_renewal_request_for(token_sha)
    token = load_token(token_sha)
    request_subject = "[#{ token.token_file.parent.human_readable_type } Access Request] Renewed Access to File (id: #{token.noid})"
    request_body = "Previously, I had been granted temporary access to a restricted file in CurateND (id: #{token.noid}). I no longer have access to the file and would like to view it again.\n\nHere is the access token I was given:\n #{token_sha}"
    request_html = <<-markup
      <a class="btn btn-default" href="mailto:#{URI.escape(token.request_recipient)}?subject=#{URI.escape(request_subject)}&body=#{URI.escape(request_body)}">Request an Access Extension</a>
    markup
  end

  def request_recipient
    return this_request["access_request_recipient"] if this_request["access_request_method"] == "email"
    # return some metadata field if this_request["access_request_method"] == "metadata"
    nil
  end

  def this_request
    @this_request ||= self.class.access_request_data[parent_class_name]
  end

  def token_file
    @token_file ||= ActiveFedora::Base.load_instance_from_solr(Sufia::Noid.namespaceize(noid))
  end

  def parent_class_name
    @parent_class_name ||= token_file.parent.class.to_s.downcase
  end

  # Data file controlling all access requests
  def self.access_request_data
    @@access_request_data ||= YAML.load( File.open( Rails.root.join( 'config/access_request_map.yml' ) ) ).freeze
  end
end
