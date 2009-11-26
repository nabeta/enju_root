class AddCreatorToFrbrModel < ActiveRecord::Migration
  def self.up
    add_column :works, :creator_id, :integer
    add_column :expressions, :creator_id, :integer
    add_column :manifestations, :creator_id, :integer
    add_column :items, :creator_id, :integer
    add_column :patrons, :creator_id, :integer
  end

  def self.down
    remove_column :works, :creator_id
    remove_column :expressions, :creator_id
    remove_column :manifestations, :creator_id
    remove_column :items, :creator_id
    remove_column :patrons, :creator_id
  end
end
