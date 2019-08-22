class ApiTransactionFile < ActiveRecord::Base
  self.table_name = 'api_transaction_files'
  belongs_to :api_transaction, foreign_key: 'trx_id'
  validates :file_seq_nbr, uniqueness: {scope: [:trx_id, :file_id]}

  def self.next_seq_nbr(trx_id:, file_id:)
    begin
      find_file = ApiTransactionFile.where(trx_id: trx_id, file_id: file_id).order(file_seq_nbr: :desc).first
    rescue ActiveRecord::RecordNotFound
      return 1
    end
    return 1 if find_file.nil?
    1 + find_file.file_seq_nbr
  end
end
