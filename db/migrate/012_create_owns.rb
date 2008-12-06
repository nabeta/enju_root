class CreateOwns < ActiveRecord::Migration
  def self.up
    create_table :owns do |t|
      t.column :patron_id, :integer, :null => false
      t.column :item_id, :integer, :null => false
      t.string :type
      t.column :position, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :owns, :patron_id
    add_index :owns, :item_id
    add_index :owns, :type
  end

  def self.down
    drop_table :owns
  end
end
