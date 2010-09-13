class CreateWorkRelationships < ActiveRecord::Migration
  def self.up
    create_table :work_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :work_relationship_type_id
      t.integer :position

      t.timestamps
    end
    add_index :work_relationships, :parent_id
    add_index :work_relationships, :child_id
  end

  def self.down
    drop_table :work_relationships
  end
end
