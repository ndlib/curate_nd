class CreateApiAccessTokens < ActiveRecord::Migration
  def change
    create_table :api_access_tokens, id: false, primary_key: :sha do |t|
      t.string :sha, null: false
      t.string :issued_by
      t.belongs_to :user, index: true

      t.timestamps
    end
    add_index :api_access_tokens, :sha, unique: true
  end

  def self.down
    drop_table :api_access_tokens
  end
end
