class ApiTransactionFile < ActiveRecord::Base
  self.table_name = 'api_transaction_files'
  belongs_to :api_transaction, foreign_key: 'trx_id'
  self.primary_keys = :trx_id, :file_id, :file_seq_nbr
  validates :file_seq_nbr, uniqueness: {scope: [:trx_id, :file_id]}

  def self.next_seq_nbr(trx_id:, file_id:)
    find_file = ApiTransactionFile.find(trx_id: trx_id, file_id: file_id).last
    return 1 unless find_files.exists?
    1 + find_file.file_seq_nbr
  end
end
