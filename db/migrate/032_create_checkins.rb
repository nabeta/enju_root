class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.column :item_id, :integer, :null => false
      t.column :librarian_id, :integer
      t.column :basket_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    add_index :checkins, :item_id
    add_index :checkins, :librarian_id
    add_index :checkins, :basket_id
  end

  def self.down
    drop_table :checkins
  end
end
