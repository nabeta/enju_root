class CreateExpressionHasExpressions < ActiveRecord::Migration
  def self.up
    create_table :expression_has_expressions do |t|
      t.integer :from_expression_id
      t.integer :to_expression_id
      t.string :type
      t.integer :position

      t.timestamps
    end
    add_index :expression_has_expressions, :from_expression_id
    add_index :expression_has_expressions, :to_expression_id
    add_index :expression_has_expressions, :type
  end

  def self.down
    drop_table :expression_has_expressions
  end
end
