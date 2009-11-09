class AddDateIndexToAdvertisement < ActiveRecord::Migration
  def self.up
    add_index :advertisements, :started_at
    add_index :advertisements, :ended_at
  end

  def self.down
    remove_index :advertisements, :started_at
    remove_index :advertisements, :ended_at
  end
end
