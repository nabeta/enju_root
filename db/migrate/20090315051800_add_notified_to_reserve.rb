class AddNotifiedToReserve < ActiveRecord::Migration
  def self.up
    add_column :reserves, :notified, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :reserves, :notified
  end
end
