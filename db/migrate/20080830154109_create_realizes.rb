class CreateRealizes < ActiveRecord::Migration
  def self.up
    create_table :realizes do |t|
      t.integer :patron_id, :null => false
      t.integer :expression_id, :null => false
      t.integer :position
      t.string :type

      t.timestamps
    end
    add_index :realizes, :patron_id
    add_index :realizes, :expression_id
    add_index :realizes, :type
  end

  def self.down
    drop_table :realizes
  end
end
