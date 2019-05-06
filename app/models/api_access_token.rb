class ApiAccessToken < ActiveRecord::Base
  self.primary_key = 'sha'
  belongs_to :user
  validates_presence_of :issued_by
  validates_uniqueness_of :sha
  before_create :assign_new_sha
  paginates_per 10

  def assign_new_sha
    assign_attributes(sha: generate_sha)
  end
  private :assign_new_sha

  def generate_sha
    SecureRandom.urlsafe_base64(32, false)
  end
  private :generate_sha
end
