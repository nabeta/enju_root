class AddIndexOnUpdatedAtToManifestation < ActiveRecord::Migration
  def self.up
    add_index :manifestations, :updated_at
    add_index :resources, :updated_at
  end

  def self.down
    remove_index :manifestations, :updated_at
    remove_index :resources, :updated_at
  end
end
