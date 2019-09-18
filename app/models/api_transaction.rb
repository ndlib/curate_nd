class ApiTransaction < ActiveRecord::Base
  self.primary_key = 'trx_id'
  belongs_to :user
  validates_presence_of :user_id
  validates_uniqueness_of :trx_id
  has_many :api_transaction_files, foreign_key: :trx_id, dependent: :destroy

  NEW_STATE_FOR_ACTION = {
    new: 'new_transaction',
    update: 'transaction_updated',
    commit: 'submitted_for_ingest',
    success: 'ingest_complete',
    error: 'error_during_ingest'
  }.freeze

  def self.new_trx_id
    # use whatever method is desired here to set a trx id
    loop do
      trx_id = SecureRandom.hex(8)
      break trx_id unless ApiTransaction.where(trx_id: trx_id).exists?
    end
  end

  def self.status_for(action:)
    NEW_STATE_FOR_ACTION.fetch(action, nil)
  end

  def self.set_status_based_on(trx_id:, action:)
    new_status = NEW_STATE_FOR_ACTION.fetch(action, nil)
    if new_status
      self.update(trx_id, trx_status: new_status)
      return true
    end
    false
  end
end
