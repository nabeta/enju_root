class CreateReifies < ActiveRecord::Migration
  def self.up
    create_table :reifies do |t|
      t.references :work, :null => false
      t.references :expression, :null => false
      t.integer :position
      t.string :type
      t.timestamps
    end
    add_index :reifies, :work_id
    add_index :reifies, :expression_id
    add_index :reifies, :type
  end

  def self.down
    drop_table :reifies
  end
end
