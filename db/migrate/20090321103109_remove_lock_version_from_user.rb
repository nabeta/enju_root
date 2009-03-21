class RemoveLockVersionFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :lock_version
  end

  def self.down
    add_column :users, :lock_version, :integer, :default => 0, :null => false
  end
end
