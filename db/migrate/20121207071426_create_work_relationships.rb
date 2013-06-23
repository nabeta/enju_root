class CreateWorkRelationships < ActiveRecord::Migration
  def change
    create_table :work_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :work_relationship_type_id

      t.timestamps
    end
    add_index :work_relationships, :parent_id
    add_index :work_relationships, :child_id
  end
end
