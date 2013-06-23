class CreateExpressionRelationships < ActiveRecord::Migration
  def change
    create_table :expression_relationships do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :expression_relationship_type_id

      t.timestamps
    end
  end
end
