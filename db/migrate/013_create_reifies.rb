class CreateReifies < ActiveRecord::Migration
  def self.up
    create_table :reifies do |t|
      t.integer :work_id, :null => false
      t.integer :expression_id, :null => false
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
