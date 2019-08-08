class ApiTransactions < ActiveRecord::Base
  self.primary_key = 'trx_id'
  belongs_to :user
  validates_presence_of :user_id
  validates_uniqueness_of :trx_id
  before_create :assign_new_trx_id

  def assign_new_trx_id
    assign_attributes(trx_id: generate_trx_id)
  end
  private :assign_new_trx_id

  def generate_trx_id
    # fill in whatever method is desired here
    SecureRandom.urlsafe_base64(32, false)
  end
  private :generate_trx_id
end
