class AddRepositoryIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :repository_id, :string
  end
end
