class RemoveNonUsedColumnFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :salt
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    remove_column :users, :activation_code
    remove_column :users, :activated_at
  end

  def self.down
    add.column :users, :salt, :string, :limit => 40
    add.column :users, :remember_token, :string
    add.column :users, :remember_token_expires_at, :datetime
    add.column :users, :activation_code, :string, :limit => 40
    add.column :users, :activated_at, :datetime
  end
end
