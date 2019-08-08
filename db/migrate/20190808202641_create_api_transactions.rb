class CreateApiTransactions < ActiveRecord::Migration
  def change
    create_table :api_transactions, id: false, primary_key: :trx_id do |t|
      t.string :trx_id, null: false
      t.string :trx_status
      t.belongs_to :user, index: true

      t.timestamps
    end
    add_index :api_transactions, :trx_id, unique: true
    add_index :api_transactions, [:user_id, :trx_id], unique: true
  end

  def self.down
    drop_table :api_transactions
  end
end
