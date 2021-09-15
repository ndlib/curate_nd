class CreateOrphanFileRequests < ActiveRecord::Migration
  def change
    create_table :orphan_file_requests do |t|
      t.string :user_id
      t.string :user_email
      t.string :file_id
      t.string :work_id
      t.datetime :completed_date

      t.timestamps
    end
    add_index :orphan_file_requests, :user_id
  end

  def self.down
    drop_table :orphan_file_requests
  end
end
