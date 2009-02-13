class CreateAdvertises < ActiveRecord::Migration
  def self.up
    create_table :advertises do |t|
      t.references :patron, :polymorphic => true
      t.integer :advertisement_id, :null => false
      t.integer :position

      t.timestamps
    end
    add_index :advertises, :patron_id
    add_index :advertises, :advertisement_id
  end

  def self.down
    drop_table :advertises
  end
end
