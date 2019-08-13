class AddWorkIdToApiTransaction < ActiveRecord::Migration
  def change
    add_column :api_transactions, :work_id, :string
  end

  def self.down
    remove_column :api_transactions, :work_id, :string
  end
end
