class AddUpdatingUserToOrphanFileRequest < ActiveRecord::Migration
  def change
    add_column :orphan_file_requests, :updating_user_id, :string
  end

  def self.down
    remove_column :orphan_file_requests, :updating_user_id, :string
  end
end
