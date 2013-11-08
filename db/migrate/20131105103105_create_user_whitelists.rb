class CreateUserWhitelists < ActiveRecord::Migration
  def self.up
    create_table :user_whitelists do |t|
      t.string :username
    end
  end

  def self.down
    drop_table :user_whitelists
  end
end
