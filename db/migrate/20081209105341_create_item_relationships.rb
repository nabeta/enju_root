class CreateItemRelationships < ActiveRecord::Migration
  def self.up
    create_table :item_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :item_relationship_type_id
      t.integer :position

      t.timestamps
    end
    add_index :item_relationships, :parent_id
    add_index :item_relationships, :child_id
  end

  def self.down
    drop_table :item_relationships
  end
end
