class CreateEmbodies < ActiveRecord::Migration
  def change
    create_table :embodies do |t|
      t.references :expression
      t.references :manifestation

      t.timestamps
    end
    add_index :embodies, :expression_id
    add_index :embodies, :manifestation_id
  end
end
