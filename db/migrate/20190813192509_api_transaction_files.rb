class ApiTransactionFiles < ActiveRecord::Migration
  def change
    create_table :api_transaction_files do |t|
      t.string :trx_id, null: false
      t.string :file_id, null: false
      t.integer :file_seq_nbr, null: false

      t.timestamps
    end
    add_index :api_transaction_files, [:trx_id, :file_id]
    add_index :api_transaction_files, [:trx_id, :file_id, :file_seq_nbr], unique: true, :name => 'unique_index'
  end

  def self.down
    drop_table :api_transaction_files
  end
end
