class CreateExpressionHasExpressions < ActiveRecord::Migration
  def self.up
    create_table :expression_has_expressions do |t|
      t.integer :from_expression_id
      t.integer :to_expression_id
      t.integer :expression_relationship_type_id
      t.integer :position

      t.timestamps
    end
    add_index :expression_has_expressions, :from_expression_id
    add_index :expression_has_expressions, :to_expression_id
    add_index :expression_has_expressions, :expression_relationship_type_id, :name => 'index_expression_has_expressions_on_r_type_id'
  end

  def self.down
    drop_table :expression_has_expressions
  end
end
