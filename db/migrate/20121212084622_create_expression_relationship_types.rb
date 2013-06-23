class CreateExpressionRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :expression_relationship_types do |t|
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
