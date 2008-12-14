class CreateItemHasItems < ActiveRecord::Migration
  def self.up
    create_table :item_has_items do |t|
      t.integer :from_item_id
      t.integer :to_item_id
      t.integer :item_relationship_type_id
      t.integer :position

      t.timestamps
    end
    add_index :item_has_items, :from_item_id
    add_index :item_has_items, :to_item_id
    add_index :item_has_items, :item_relationship_type_id
  end

  def self.down
    drop_table :item_has_items
  end
end
