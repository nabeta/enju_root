class CreateDonates < ActiveRecord::Migration
  def self.up
    create_table :donates do |t|
      t.integer :patron_id
      t.integer :item_id

      t.timestamps
    end
    add_index :donates, :patron_id
    add_index :donates, :item_id
  end

  def self.down
    drop_table :donates
  end
end
