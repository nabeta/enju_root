class CreateExemplifies < ActiveRecord::Migration
  def change
    create_table :exemplifies do |t|
      t.references :manifestation
      t.references :item

      t.timestamps
    end
    add_index :exemplifies, :manifestation_id
    add_index :exemplifies, :item_id
  end
end
