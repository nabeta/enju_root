class CreateReifies < ActiveRecord::Migration
  def change
    create_table :reifies do |t|
      t.references :work
      t.references :expression

      t.timestamps
    end
    add_index :reifies, :work_id
    add_index :reifies, :expression_id
  end
end
