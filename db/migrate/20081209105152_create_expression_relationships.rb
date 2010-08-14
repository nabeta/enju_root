class CreateExpressionRelationships < ActiveRecord::Migration
  def self.up
    create_table :expression_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :expression_relationship_type_id
      t.integer :position

      t.timestamps
    end
    add_index :expression_relationships, :parent_id
    add_index :expression_relationships, :child_id
  end

  def self.down
    drop_table :expression_relationships
  end
end
